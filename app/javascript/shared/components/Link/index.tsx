import clsx from 'clsx';
import type { FunctionComponent, JSX } from 'preact';
import { Link as WouterLink } from 'wouter-preact'; // eslint-disable-line no-restricted-imports

import styles from './styles.module.css';

export type LinkProps = Omit<JSX.IntrinsicElements['a'], 'href'> & {
  external?: true;
  href: string;
  unstyled?: true;
  skipRouter?: true;
};

const Link: FunctionComponent<LinkProps> = ({
  class: className,
  children,
  external,
  href,
  unstyled,
  skipRouter = external,
  ...rest
}) =>
  skipRouter || href.startsWith('#') || href.startsWith('mailto:') ? (
    <a class={clsx(className, !unstyled && styles.link)} href={href} {...rest}>
      {children}
    </a>
  ) : (
    <WouterLink href={href}>
      <a class={clsx(className, !unstyled && styles.link)} {...rest}>
        {children}
      </a>
    </WouterLink>
  );

export default Link;
