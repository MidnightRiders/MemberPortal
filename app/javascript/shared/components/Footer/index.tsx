import Link from '~shared/components/Link';
import { useAuthCtx } from '~shared/contexts/auth';

import styles from './styles.module.css';

const Footer = () => {
  const { user } = useAuthCtx();

  return (
    <footer className={styles.pageFooter}>
      <nav>
        <a href="/faq">Frequently Asked Questions</a> &bull;{' '}
        <a href="/contact">Contact Us</a>
        {!user && (
          <>
            &bull; <a href="/users/sign_up">Sign Up</a> &bull;{' '}
            <Link href="/sign-in">Sign In</Link>
          </>
        )}
      </nav>
      <p>
        Copyright ©1995 – {new Date().getFullYear()}, Midnight Riders. MLS and
        club logos are copyright their respective owners.{' '}
        <a href="mailto:webczar+membersite@midnightriders.com">Webmaster</a>
      </p>
    </footer>
  );
};

export default Footer;
