import clsx from 'clsx';
import { useState } from 'preact/hooks';
import type { IconName } from '~shared/components/Icon';
import Icon from '~shared/components/Icon';

import { useOnMount } from '~shared/hooks/effects';

import styles from './styles.module.css';

const ERROR_ICON_MAP: Record<string, IconName | undefined> = {
  default: 'exclamation-triangle-fill',
};

const ErrorDisplay = ({
  message,
  origin,
}: {
  message: string;
  origin: string;
}) => {
  const [mounted, setMounted] = useState(false);

  const icon = ERROR_ICON_MAP[origin] ?? ERROR_ICON_MAP.default!;

  useOnMount(() => {
    setTimeout(() => {
      setMounted(true);
    }, 10);
  });

  return (
    <div className={clsx(styles.error, mounted && styles.mounted)}>
      <Icon name={icon} /> {message}
    </div>
  );
};

export default ErrorDisplay;
