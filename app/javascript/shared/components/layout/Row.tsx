import clsx from 'clsx';
import type { FunctionComponent, JSX } from 'preact';

import styles from './styles.module.css';

const Row: FunctionComponent<JSX.IntrinsicElements['div'] & { center?: boolean }> = ({
  class: className,
  center,
  children,
  ...rest
}) => (
  <div className={clsx(className, styles.row, center && styles.center)} {...rest}>
    {children}
  </div>
);

export default Row;
