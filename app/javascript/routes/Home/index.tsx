import { useAuthCtx } from '~shared/contexts/auth';
import { useOnMount } from '~shared/hooks/effects';
import makeRoute from '~shared/makeRoute';
import { pageTitle } from '~shared/signals/app';

const Home = makeRoute('/', () => {
  const { user } = useAuthCtx();

  useOnMount(() => {
    const prevValue = pageTitle.value;
    pageTitle.value = 'Member Portal | Home';
    return () => {
      pageTitle.value = prevValue;
    };
  });

  if (!user) {
    return (
      <>
        <h2>Welcome</h2>

        <p>
          Please sign in using the link in the top corner, or{' '}
          <a href="mailto:webczar+memberportal@midnightriders.com">email us</a>{' '}
          to gain access.
        </p>
      </>
    );
  }

  return <>TODO</>;
});

export default Home;
