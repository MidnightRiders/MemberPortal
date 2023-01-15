import clsx from 'clsx';
import type { JSX } from 'preact';
import { FaBrandIcon, FaIcon, useIconSet } from './values';

interface IconComponent {
  (props: { name: FaIcon | FaBrandIcon }): JSX.Element;
  (props: { name: FaIcon; style: 'solid' | 'regular' }): JSX.Element;
}

const Icon: IconComponent = ({
  name,
  style,
}: {
  name: FaIcon | FaBrandIcon;
  style?: 'solid' | 'regular';
}) => {
  const iconSet = useIconSet(name, style);
  return <i class={clsx(iconSet, `fa-${name}`)} />;
};

export default Icon;
