import Link from '~shared/components/Link';
import { useAuthCtx } from '~shared/contexts/auth';
import Paths from '~shared/paths';

import styles from './styles.module.css';

const Footer = () => {
  const { user } = useAuthCtx();

  return (
    <footer className={styles.pageFooter}>
      <nav>
        <Link unstyled href={Paths.FAQ}>
          Frequently Asked Questions
        </Link>{' '}
        &bull;{' '}
        <Link unstyled href={Paths.ContactUs}>
          Contact Us
        </Link>
        {!user && (
          <>
            &bull;{' '}
            <Link unstyled href={Paths.SignUp}>
              Sign Up
            </Link>{' '}
            &bull;{' '}
            <Link unstyled href={Paths.SignIn}>
              Sign In
            </Link>
          </>
        )}
      </nav>
      <p>
        Copyright ©1995 – {new Date().getFullYear()}, Midnight Riders. MLS and
        club logos are copyright their respective owners.{' '}
        <Link
          external
          unstyled
          href="mailto:webczar+membersite@midnightriders.com"
        >
          Webmaster
        </Link>
      </p>
    </footer>
  );
};

export default Footer;
