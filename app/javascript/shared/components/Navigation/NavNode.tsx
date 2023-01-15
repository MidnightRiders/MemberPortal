import clsx from 'clsx';
import type { ComponentChild, JSX } from 'preact';
import { Link } from 'wouter-preact';
import Icon, { IconName } from '../Icon';

import { Expandable } from './Expandable';

import styles from './styles.module.css';

export type Node =
  | (({
      gap?: boolean;
      icon?: IconName;
    } & (
      | {
          content: string;
          collapse?: boolean;
        }
      | {
          content: Exclude<ComponentChild, string>;
          collapse?: string;
        }
    )) &
      (
        | {
            href: string;
            external?: boolean;
          }
        | {
            onClick: JSX.GenericEventHandler<HTMLButtonElement>;
          }
        | {
            type?: 'group' | 'dropdown';
            children: Node[];
          }
      ))
  | {
      divider: true;
    }
  | (false | null | undefined)
  | Node[];

const titleFromNode = (node: Node) => {
  if (!node) return {};
  if (!('collapse' in node)) return {};

  if (typeof node.collapse === 'string') return { title: node.collapse };
  if (typeof node.content === 'string') return { title: node.content };
  return {};
};

const NavNode = ({ node }: { node: Node }) => {
  if (!node) return null;

  if ('children' in node) {
    const { children, content, type = 'dropdown' } = node;
    if (type === 'dropdown') {
      return (
        <Expandable
          content={content}
          icon={node.icon}
          gap={node.gap ?? false}
          nodes={children}
          {...titleFromNode(node)}
        />
      );
    }
    return (
      <>
        <li
          class={clsx(
            styles.groupHeader,
            node.gap && styles.gap,
            node.collapse && styles.collapse,
          )}
          {...titleFromNode(node)}
        >
          {node.icon && <Icon name={node.icon} />} <span>{content}</span>
        </li>
        {children.map((n) => (
          <NavNode node={n} />
        ))}
      </>
    );
  }
  if ('divider' in node) return <hr />;
  if (Array.isArray(node)) {
    return (
      <>
        {node.map((n) => (
          <NavNode node={n} />
        ))}
      </>
    );
  }
  if ('onClick' in node) {
    return (
      <li class={clsx(node.gap && styles.gap)}>
        <button
          type="button"
          class={clsx(node.collapse && styles.collapse)}
          onClick={node.onClick}
          {...titleFromNode(node)}
        >
          {node.icon && <Icon name={node.icon} />} <span>{node.content}</span>
        </button>
      </li>
    );
  }

  const { external, gap, href, icon, content, collapse, ...rest } = node;
  const El = external ? 'a' : Link;
  const linkProps = {
    ...titleFromNode(node),
    class: clsx(collapse && styles.collapse),
  };
  return (
    <li class={clsx(gap && styles.gap)}>
      <El
        href={href}
        {...(external ? { target: '_blank', rel: 'noreferrer' } : {})}
        {...linkProps}
      >
        {!external ? (
          <a {...linkProps}>
            {icon && <Icon name={icon} />} <span>{content}</span>
          </a>
        ) : (
          <>
            {icon && <Icon name={icon} />} <span>{content}</span>
          </>
        )}
      </El>
    </li>
  );
};

export default NavNode;
