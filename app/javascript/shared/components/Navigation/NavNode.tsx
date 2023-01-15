import clsx from 'clsx';
import type { ComponentChild, JSX } from 'preact';
import { Link } from 'wouter-preact';

import { Expandable } from './Expandable';

import styles from './styles.module.css';

export type Node =
  | ({
      content: ComponentChild;
      gap?: boolean;
    } & (
      | {
          href: string;
          external?: boolean;
          title?: string;
        }
      | {
          onClick: JSX.GenericEventHandler<HTMLButtonElement>;
          title?: string;
        }
      | {
          type?: 'group' | 'dropdown';
          children: Node[];
          title?: string;
        }
    ))
  | {
      divider: true;
    }
  | (false | null | undefined)
  | Node[];

const NavNode = ({ node }: { node: Node }) => {
  if (!node) return null;

  if ('children' in node) {
    const { children, content, type = 'dropdown' } = node;
    if (type === 'dropdown') {
      return (
        <Expandable
          content={content}
          gap={node.gap ?? false}
          nodes={children}
        />
      );
    }
    return (
      <>
        <li
          class={clsx(styles.groupHeader, node.gap && styles.gap)}
          {...(node.title ? { title: node.title } : {})}
        >
          {content}
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
          onClick={node.onClick}
          {...(node.title ? { title: node.title } : {})}
        >
          {node.content}
        </button>
      </li>
    );
  }

  const { external, gap, href, content, title, ...rest } = node;
  const El = external ? 'a' : Link;
  return (
    <li class={clsx(gap && styles.gap)}>
      <El
        href={href}
        {...(external ? { target: '_blank', rel: 'noreferrer' } : {})}
        {...(title ? { title: title } : {})}
        {...rest}
      >
        {!external ? <a>{content}</a> : content}
      </El>
    </li>
  );
};

export default NavNode;
