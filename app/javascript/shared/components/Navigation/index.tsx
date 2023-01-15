import clsx from 'clsx';
import type { JSX } from 'preact';
import { useCallback, useState } from 'preact/hooks';

import NavNode from '~shared/components/Navigation/NavNode';
import useNav from '~shared/components/Navigation/useNav';

import styles from './styles.module.css';

const Navigation = () => {
  const navItems = useNav();
  const [mobileExpand, setMobileExpand] = useState(false);

  const toggleMobileExpand = useCallback<
    JSX.GenericEventHandler<HTMLButtonElement>
  >((e) => {
    e.preventDefault();
    setMobileExpand((v) => !v);
  }, []);

  return (
    <nav class={styles.nav}>
      <button
        type="button"
        class={styles.mobileExpand}
        onClick={toggleMobileExpand}
      >
        <i class="fa-solid fa-bars fa-fw" /> Menu
      </button>
      <ul class={clsx(mobileExpand && styles.mobileExpanded)}>
        {navItems.map((node) => (
          <NavNode node={node} />
        ))}
      </ul>
    </nav>
  );
};

export default Navigation;
