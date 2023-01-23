import { Elements } from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';
import { useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';

import Icon from '~shared/components/Icon';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { useAuthCtx } from '~shared/contexts/auth';
import { usePost } from '~shared/contexts/errors/fetch';
import { useOnMount } from '~shared/hooks/effects';
import makeRoute from '~shared/makeRoute';
import Paths, { pathTo } from '~shared/paths';

const stripePromise = loadStripe(import.meta.env.VITE_STRIPE_PUBLIC_KEY);

const UserNewMembership = makeRoute(Paths.UserNewMembership, () => {
  const { user } = useAuthCtx();

  const [token, setToken] = useState('');
  const post = usePost('purchaseToken');
  useOnMount(async () => {
    const resp = await post<{ token: string }>('/api/puchases/payment-intent', {
      item: 'individual', // TODO
    });

    if (!resp) return;
    setToken(resp.token);
  });

  if (user?.isCurrentMember) {
    return <Redirect to={pathTo(Paths.UserMembership, user.id)} />;
  }

  if (!token) {
    return (
      <div className="loading" alt="loading" title="Loading…">
        <Icon name="arrow-clockwise" />
      </div>
    );
  }

  return (
    <Row>
      <Column size={3}>
        <h2 class="white">New Membership</h2>
      </Column>
      <Column size={9}>
        <Elements stripe={stripePromise} token={token} />
      </Column>
    </Row>
  );
});

export default UserNewMembership;
