import { useCallback, useEffect, useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';

import Icon from '~shared/components/Icon';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { useAuthCtx } from '~shared/contexts/auth';
import { useGet, usePost } from '~shared/contexts/errors/fetch';
import { useOnMount } from '~shared/hooks/effects';
import makeRoute from '~shared/makeRoute';
import Paths, { pathTo } from '~shared/paths';

import StripeForm from './StripeForm';

interface Product {
  name: string;
  price: number;
  description: string;
  stripePrice: string;
}

const UserNewMembership = makeRoute(Paths.UserNewMembership, () => {
  const { user } = useAuthCtx();

  const [token, setToken] = useState('');
  const [products, setProducts] = useState<(Product & { id: string })[] | null>(null);
  const [selectedProduct, setSelectedProduct] = useState<string>();
  const productsGet = useGet('products');
  useOnMount(async () => {
    const resp = await productsGet<{ products: Record<string, Product> }>('/api/purchases/products?type=memberships');

    if (!resp) return;

    const newProds = Object.entries(resp.products).map(([id, product]) => ({
      id,
      ...product,
    }));
    setProducts(newProds);
    if (newProds.length === 1) setSelectedProduct(newProds[0].id);
  });

  const tokenPost = usePost('purchaseToken');
  useEffect(() => {
    if (!selectedProduct) return;

    tokenPost<{ token: string }>('/api/purchases/payment-intent', {
      type: 'memberships',
      item: selectedProduct,
    }).then((resp) => {
      if (!resp) return;

      setToken(resp.token);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedProduct]);

  const handleSubmit = useCallback(() => {
    window.history.pushState({}, '', pathTo(Paths.UserCurrentMembership, { userId: user!.id }));
  }, [user]);

  if (user?.isCurrentMember) {
    return <Redirect to={pathTo(Paths.UserMembership, user.id)} />;
  }

  if (!products?.length || (selectedProduct && !token)) {
    return (
      <div class="loading" alt="loading" title="Loading…">
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
        {token ? (
          <StripeForm token={token} onSubmit={handleSubmit} />
        ) : (
          <Block>
            {products.map((product) => (
              <button type="button" onClick={() => setSelectedProduct(product.id)}>
                <h3>{product.name}</h3>
                <h4>${Intl.NumberFormat('en-US', { currency: 'USD' }).format(product.price)}</h4>
                <p>{product.description}</p>
              </button>
            ))}
          </Block>
        )}
      </Column>
    </Row>
  );
});

export default UserNewMembership;
