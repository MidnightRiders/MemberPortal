import { Link } from 'wouter-preact';
import { useAuthCtx } from '~shared/contexts/auth';

const Footer = () => {
  const { user } = useAuthCtx();

  return (
    <footer>
      <nav>
        <a href="/faq">Frequently Asked Questions</a>{' '}
        <a href="/contact">Contact Us</a>
        {!user && (
          <>
            {' '}
            <a href="/users/sign_up">Sign Up</a>{' '}
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
