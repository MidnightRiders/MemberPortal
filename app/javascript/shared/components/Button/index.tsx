import clsx from 'clsx';
import { cloneElement, JSX } from 'preact';
import { Link } from 'wouter-preact';
import Icon from '../Icon';
import { FaBrandIcon, FaIcon } from '../Icon/values';

import styles from './styles.module.css';

type Props<T extends 'a' | 'button' | typeof Link> = Omit<
  JSX.IntrinsicElements[T extends typeof Link ? 'a' : T],
  'as' | 'secondary' | 'primary'
> & {
  as?: T;
} & (
    | {
        leftIcon?: JSX.Element;
        rightIcon?: JSX.Element;
      }
    | {
        leftFa?: FaIcon | FaBrandIcon;
        rightFa?: FaIcon | FaBrandIcon;
      }
  ) &
  (
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
  ...rest
}: Props<T>) => {
  let props: any;
  let secondary = false;
  let primary = false;
  if ('secondary' in rest) {
    ({ secondary, ...props } = rest);
  } else {
    let p: unknown;
    ({ primary: p, ...props } = rest);
    primary = true;
  }

  let leftIcon: JSX.Element | null = null;
  let rightIcon: JSX.Element | null = null;
  if ('leftIcon' in props || 'leftIcon' in props) {
    ({ leftIcon, rightIcon } = props);
  } else if ('leftFa' in props || 'rightFa' in props) {
    const { leftFa, rightFa } = props;
    if (leftFa) {
      leftIcon = <Icon name={leftFa} />;
    }
    if (rightFa) {
      rightIcon = <Icon name={rightFa} />;
    }
  }

  return (
    <Component
      class={clsx(
        className,
        styles.button,
        secondary && styles.secondary,
        primary && styles.primary,
      )}
      {...props}
    >
      {leftIcon && <span class={styles.leftIcon}>{leftIcon}</span>}
      {children}
      {rightIcon && <span class={styles.rightIcon}>{rightIcon}</span>}
    </Component>
  );
};

export default Button;
