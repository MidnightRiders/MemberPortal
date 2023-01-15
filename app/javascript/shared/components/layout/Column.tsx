import clsx from 'clsx';
import { FunctionComponent, JSX } from 'preact';

import styles from './styles.module.css';

const Column: FunctionComponent<
  JSX.IntrinsicElements['div'] & {
    columns?: number;
    center?: boolean;
    offset?: number;
  }
> = ({
  class: className,
  center,
  children,
  columns = 12,
  offset = 0,
  ...rest
}) => (
  <div
    className={clsx(className, styles.column, center && styles.center)}
    style={{ '--cols': columns, '--offset': center ? 0 : offset }}
    {...rest}
  >
    {children}
  </div>
);

export default Column;
