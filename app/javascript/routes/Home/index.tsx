import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { useAuthCtx } from '~shared/contexts/auth';
import { useOnMount } from '~shared/hooks/effects';
import makeRoute from '~shared/makeRoute';
import Paths from '~shared/paths';
import { pageTitle } from '~shared/signals/app';

const Home = makeRoute(Paths.Home, () => {
  // TODO: use user context
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { user } = useAuthCtx();

  useOnMount(() => {
    const prevValue = pageTitle.value;
    pageTitle.value = 'Member Portal | Home';
    return () => {
      pageTitle.value = prevValue;
    };
  });

  return (
    <Row>
      <Column>
        <Block>TODO</Block>
      </Column>
    </Row>
  );
});

export default Home;
