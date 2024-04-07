import clsx from 'clsx';
import type { JSX } from 'preact';

import styles from './styles.module.css';

type Props<T extends keyof JSX.IntrinsicElements> = Omit<JSX.IntrinsicElements[T], 'as'> & {
  as?: T;
};

const Block = <T extends keyof JSX.IntrinsicElements = 'div'>({
  as: Component = 'div' as T,
  class: className,
  children,
  ...rest
}: Props<T>) => (
  <Component class={clsx(className, styles.block)} {...(rest as any)}>
    {children}
  </Component>
);

export default Block;
