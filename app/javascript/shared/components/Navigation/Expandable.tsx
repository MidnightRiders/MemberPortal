import clsx from 'clsx';
import type { ComponentChild, JSX } from 'preact';
import { useCallback, useEffect, useState } from 'preact/hooks';
import { useLocation } from 'wouter-preact';
import Icon, { IconName } from '../Icon';
import NavNode, { Node } from './NavNode';

import styles from './styles.module.css';

interface Props {
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
}: Props) => {
  const [expanded, setExpanded] = useState(false);
  const toggle = useCallback(() => setExpanded((e) => !e), []);
  const [location] = useLocation();

  useEffect(() => {
    setExpanded(false);
  }, [location]);

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
        class={clsx(
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
            <NavNode node={node} />
          ))}
        </ul>
      )}
    </li>
  );
};

export default Expandable;
