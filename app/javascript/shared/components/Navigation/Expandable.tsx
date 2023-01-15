import clsx from 'clsx';
import type { ComponentChild, JSX, Ref, RefObject } from 'preact';
import { useCallback, useState } from 'preact/hooks';
import NavNode, { Node } from './NavNode';

import styles from './styles.module.css';

interface Props {
  content: ComponentChild;
  gap?: boolean;
  nodes: Node[];
}

export const Expandable = ({ content, gap = false, nodes }: Props) => {
  const [expanded, setExpanded] = useState(false);
  const toggle = useCallback(() => setExpanded((e) => !e), []);

  return (
    <li class={clsx(styles.expandable, gap && styles.gap)}>
      <button
        type="button"
        class={clsx(styles.expand, expanded && styles.expanded)}
        onClick={toggle}
      >
        {content}
      </button>
      {expanded && (
        <ul>
          {nodes.map((node) => (
            <NavNode node={node} />
          ))}
        </ul>
      )}
    </li>
  );
};

export default Expandable;
