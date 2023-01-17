import clsx from 'clsx';
import { FunctionComponent, JSX } from 'preact';

import styles from './styles.module.css';

export type ColSize = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12;

const Column: FunctionComponent<
  Omit<JSX.IntrinsicElements['div'], 'size'> & {
    size?: ColSize;
    center?: boolean;
    offset?: number;
  }
> = ({
  class: className,
  center,
  children,
  size = 12,
  offset = 0,
  ...rest
}) => (
  <div
    className={clsx(className, styles.column, center && styles.center)}
    style={{ '--cols': size, '--offset': center ? 0 : offset }}
    {...rest}
  >
    {children}
  </div>
);

export default Column;
