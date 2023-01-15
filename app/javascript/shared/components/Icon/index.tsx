import type { IconName } from './values';

const Icon = ({ name }: { name: IconName }) => <i className={`bi-${name}`} />;

export { IconName };

export default Icon;
