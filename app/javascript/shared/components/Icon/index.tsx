import type { IconName } from './values';

const Icon = ({ name }: { name: IconName }) => {
  return <i class={`bi-${name}`} />;
};

export { IconName };

export default Icon;
