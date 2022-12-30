import clsx from 'clsx';
import { useState } from 'preact/hooks';

import { useOnMount } from '~shared/hooks/effects';

import styles from './styles.module.css';

const ERROR_ICON_MAP: Record<string, string | undefined> = {
  default: 'fa-solid fa-triangle-exclamation fa-fw',
};

const ErrorDisplay = ({
  message,
  origin,
}: {
  message: string;
  origin: string;
}) => {
  const [mounted, setMounted] = useState(false);

  const icon = ERROR_ICON_MAP[origin] ?? ERROR_ICON_MAP.default;

  useOnMount(() => {
    setTimeout(() => {
      setMounted(true);
    }, 10);
  });

  return (
    <div className={clsx(styles.error, mounted && styles.mounted)}>
      <i class={icon} /> {message}
    </div>
  );
};

export default ErrorDisplay;
