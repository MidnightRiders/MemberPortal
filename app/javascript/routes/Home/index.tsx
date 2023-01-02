import { Typography } from '@mui/material';
import { Body2, H2 } from '~shared/components/typography';
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
        <H2>Welcome</H2>

        <Body2>
          Please sign in using the link in the top corner, or{' '}
          <a href="mailto:webczar+memberportal@midnightriders.com">email us</a>{' '}
          to gain access.
        </Body2>
      </>
    );
  }

  return <>TODO</>;
});

export default Home;
