import clsx from 'clsx';
import type { JSX } from 'preact';

import Link from '~shared/components/Link';

import Icon, { IconName } from '../Icon';

import styles from './styles.module.css';

type Props<T extends 'a' | 'button' | typeof Link> = Omit<
  JSX.IntrinsicElements[T extends typeof Link ? 'a' : T],
  'as' | 'secondary' | 'primary'
> & {
  as?: T;
  ghost?: true;
  leftIcon?: JSX.Element | IconName;
  rightIcon?: JSX.Element | IconName;
} & (
    | {
        primary?: true;
      }
    | {
        secondary: true;
      }
  );

const Button = <T extends 'a' | 'button' | typeof Link = 'button'>({
  as: Component = 'button' as T,
  class: className,
  children,
  ghost,
  leftIcon,
  rightIcon,
  ...rest
}: Props<T>) => {
  let props: any;
  let secondary = false;
  let primary = false;
  if ('secondary' in rest) {
    ({ secondary, ...props } = rest);
  } else {
    let _p: unknown;
    ({ primary: _p, ...props } = rest);
    primary = true;
  }

  let lfi = leftIcon;
  let rti = rightIcon;
  if (typeof lfi === 'string') {
    lfi = <Icon name={lfi} />;
  }
  if (typeof rti === 'string') {
    rti = <Icon name={rti} />;
  }

  return (
    <Component
      class={clsx(
        className,
        styles.button,
        secondary && styles.secondary,
        primary && styles.primary,
        ghost && styles.ghost,
      )}
      {...(Component === Link ? { unstyled: true } : {})}
      {...props}
    >
      {lfi && <span className={styles.leftIcon}>{lfi}</span>}
      <span>{children}</span>
      {rti && <span className={styles.rightIcon}>{rti}</span>}
    </Component>
  );
};

export default Button;
