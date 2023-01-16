import clsx from 'clsx';
import type { ComponentChild, JSX } from 'preact';
import { useCallback, useEffect, useState } from 'preact/hooks';
import { useLocation } from 'wouter-preact';

import Link from '~shared/components/Link';

import Icon, { IconName } from '../Icon';

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

interface ExpandableProps {
  content: ComponentChild;
  gap?: boolean;
  icon?: IconName | undefined;
  nodes: Node[];
  title?: string;
}

const stopPropagation = (e: Event) => e.stopPropagation();

export const Expandable = ({
  content,
  gap = false,
  icon,
  nodes,
  title,
}: ExpandableProps) => {
  const [expanded, setExpanded] = useState(false);
  const toggle = useCallback(() => setExpanded((e) => !e), []);
  const [location] = useLocation();

  useEffect(() => {
    setExpanded(false);
  }, [location]);

  useEffect(() => {
    if (!expanded) return undefined;

    let removed = false;

    const closeModal: (e: Event) => void = () => {
      setExpanded(false);
      removed = true;
      document.body.removeEventListener('click', closeModal);
    };
    document.body.addEventListener('click', closeModal);

    return () => {
      if (removed) return;
      document.body.removeEventListener('click', closeModal);
    };
  }, [expanded]);

  return (
    // This is not an interactive element; it just stops propagation of click events farther down the tree.
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <li
      className={clsx(styles.expandable, gap && styles.gap)}
      onClick={stopPropagation}
    >
      <button
        type="button"
        className={clsx(
          styles.expand,
          expanded && styles.expanded,
          title && styles.collapse,
        )}
        onClick={toggle}
        {...(title ? { title } : {})}
      >
        {icon && <Icon name={icon} />} <span>{content}</span>{' '}
        <Icon name="chevron-down" />
      </button>
      {expanded && (
        <ul>
          {nodes.map((node) => (
            // eslint-disable-next-line @typescript-eslint/no-use-before-define
            <NavNode node={node} />
          ))}
        </ul>
      )}
    </li>
  );
};

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
          className={clsx(
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
      <li className={clsx(node.gap && styles.gap)}>
        <button
          type="button"
          className={clsx(node.collapse && styles.collapse)}
          onClick={node.onClick}
          {...titleFromNode(node)}
        >
          {node.icon && <Icon name={node.icon} />} <span>{node.content}</span>
        </button>
      </li>
    );
  }

  const { external, gap, href, icon, content, collapse } = node;
  const El = external ? 'a' : Link;
  const linkProps = {
    ...titleFromNode(node),
    class: clsx(collapse && styles.collapse),
  };
  return (
    <li className={clsx(gap && styles.gap)}>
      <El
        href={href}
        {...(external
          ? { target: '_blank', rel: 'noreferrer' }
          : { unstyled: true })}
        {...linkProps}
      >
        {icon && <Icon name={icon} />} <span>{content}</span>
      </El>
    </li>
  );
};

export default NavNode;
