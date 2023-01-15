import type { FunctionComponent, JSX } from 'preact';
import { Link as WouterLink } from 'wouter-preact'; // eslint-disable-line no-restricted-imports

export type LinkProps = Omit<JSX.IntrinsicElements['a'], 'href'> & {
  href: string;
};

const Link: FunctionComponent<LinkProps> = ({ children, href, ...rest }) => (
  <WouterLink href={href}>
    <a {...rest}>{children}</a>
  </WouterLink>
);

export default Link;
