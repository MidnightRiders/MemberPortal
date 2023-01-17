import { Redirect } from 'wouter-preact';

import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { useAuthCtx } from '~shared/contexts/auth';
import makeRoute from '~shared/makeRoute';
import Paths, { pathTo } from '~shared/paths';

const UserNewMembership = makeRoute(Paths.UserNewMembership, () => {
  const { user } = useAuthCtx();

  if (user?.isCurrentMember) {
    return <Redirect to={pathTo(Paths.UserMembership, user.id)} />;
  }

  return (
    <Row>
      <Column size={3}>
        <h2 class="white">New Membership</h2>
      </Column>
      <Column size={9}>
        <Block>TODO</Block>
      </Column>
    </Row>
  );
});

export default UserNewMembership;
