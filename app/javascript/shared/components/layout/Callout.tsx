import clsx from 'clsx';
import { ComponentType, JSX, RenderableProps } from 'preact';

import styles from './styles.module.css';

type Props<T extends keyof JSX.IntrinsicElements | ComponentType<unknown>> =
  Omit<
    T extends ComponentType<infer P>
      ? RenderableProps<P>
      : T extends keyof JSX.IntrinsicElements
      ? JSX.IntrinsicElements[T]
      : never,
    'as' | 'variant'
  > & {
    as?: T;
    variant?: 'alert' | 'notice' | 'success' | 'warning';
  };

const Callout = <
  T extends keyof JSX.IntrinsicElements | ComponentType<unknown>,
>({
  as: Component = 'div' as T,
  children,
  variant = 'notice',
  ...props
}: Props<T>) => (
  // @ts-ignore
  <Component class={clsx(styles.callout, styles[variant])} {...props}>
    {/* @ts-ignore */}
    {children}
  </Component>
);

export default Callout;
