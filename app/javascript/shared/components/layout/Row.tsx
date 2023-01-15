import clsx from 'clsx';
import { JSX, FunctionComponent } from 'preact';

import styles from './styles.module.css';

const Row: FunctionComponent<
  JSX.IntrinsicElements['div'] & { center?: boolean }
> = ({ class: className, center, children, ...rest }) => (
  <div class={clsx(className, styles.row, center && styles.center)} {...rest}>
    {children}
  </div>
);

export default Row;
