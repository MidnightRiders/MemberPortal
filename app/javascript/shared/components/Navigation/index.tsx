import clsx from 'clsx';
import type { JSX } from 'preact';
import { useCallback, useEffect, useState } from 'preact/hooks';
import { useLocation } from 'wouter-preact';

import NavNode from '~shared/components/Navigation/NavNode';
import useNav from '~shared/components/Navigation/useNav';

import Icon from '../Icon';

import styles from './styles.module.css';

const Navigation = () => {
  const navItems = useNav();
  const [mobileExpand, setMobileExpand] = useState(false);
  const [location] = useLocation();

  useEffect(() => {
    setMobileExpand(false);
  }, [location]);

  const toggleMobileExpand = useCallback<
    JSX.GenericEventHandler<HTMLButtonElement>
  >((e) => {
    e.preventDefault();
    setMobileExpand((v) => !v);
  }, []);

  return (
    <nav className={styles.nav}>
      <button
        type="button"
        className={styles.mobileExpand}
        onClick={toggleMobileExpand}
      >
        <Icon name="list" /> Menu
      </button>
      <ul className={clsx(mobileExpand && styles.mobileExpanded)}>
        {navItems.map((node) => (
          <NavNode node={node} />
        ))}
      </ul>
    </nav>
  );
};

export default Navigation;
