import NavNode from '~shared/components/Navigation/NavNode';
import useNav from '~shared/components/Navigation/useNav';

import styles from './styles.module.css';

const Navigation = () => {
  const navItems = useNav();

  return (
    <nav class={styles.nav}>
      <ul>
        {navItems.map((node) => (
          <NavNode node={node} />
        ))}
      </ul>
    </nav>
  );
};

export default Navigation;
