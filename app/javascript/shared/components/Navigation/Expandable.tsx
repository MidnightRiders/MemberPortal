import clsx from 'clsx';
import type { ComponentChild, JSX } from 'preact';
import { useCallback, useEffect, useState } from 'preact/hooks';
import NavNode, { Node } from './NavNode';

import styles from './styles.module.css';

interface Props {
  content: ComponentChild;
  gap?: boolean;
  nodes: Node[];
}

const stopPropagation = (e: Event) => e.stopPropagation();

export const Expandable = ({ content, gap = false, nodes }: Props) => {
  const [expanded, setExpanded] = useState(false);
  const toggle = useCallback(() => setExpanded((e) => !e), []);

  useEffect(() => {
    if (!expanded) return;

    let removed = false;

    const closeModal = (e: MouseEvent) => {
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
    <li
      class={clsx(styles.expandable, gap && styles.gap)}
      onClick={stopPropagation}
    >
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
