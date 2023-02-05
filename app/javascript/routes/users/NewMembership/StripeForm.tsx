import type {
  StripeElements,
  StripePaymentElementOptions,
} from '@stripe/stripe-js';
import type { JSX } from 'preact';
import { useCallback, useEffect, useRef, useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';

import Button from '~shared/components/Button';
import Actions from '~shared/components/forms/Actions';
import Icon from '~shared/components/Icon';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { useAuthCtx } from '~shared/contexts/auth';
import { useErrorsCtx } from '~shared/contexts/errors';
import Paths, { pathTo } from '~shared/paths';

interface Props {
  token: string;
  onSubmit: () => void;
}

class PaymentError extends Error {
  public readonly name = 'PaymentError';
}

const waitForElement = (element: {
  on(event: 'ready', cb: () => void): void;
}) =>
  new Promise<void>((resolve) => {
    element.on('ready', resolve);
  });

const stripe = window.Stripe!(import.meta.env.VITE_STRIPE_PUBLIC_KEY);

const StripeForm = ({ token, onSubmit }: Props) => {
  const { user } = useAuthCtx();
  const { addError } = useErrorsCtx();

  const [email, setEmail] = useState(user?.email ?? '');
  const [loading, setLoading] = useState(true);

  const elementsRef = useRef<StripeElements>();
  const linkAuthenticationRef = useRef<HTMLDivElement>(null);
  const paymentRef = useRef<HTMLDivElement>(null);

  const handleSubmit: JSX.GenericEventHandler<HTMLFormElement> = useCallback(
    async (e) => {
      e.preventDefault();

      if (!elementsRef.current) return;

      if (email !== user?.email) {
        // TODO: update email
      }

      try {
        const result = await stripe.confirmPayment({
          elements: elementsRef.current,
          confirmParams: {
            return_url:
              window.location.origin +
              pathTo(Paths.UserCurrentMembership, { userId: user!.id }),
            save_payment_method: true,
          },
          redirect: 'if_required',
        });
        if (result.error) throw new PaymentError(result.error.message);
        if (result.paymentIntent.next_action?.redirect_to_url?.url) {
          window.location.assign(
            result.paymentIntent.next_action.redirect_to_url.url,
          );
          return;
        }
        if (result.paymentIntent.status !== 'succeeded') {
          throw new PaymentError(
            `Unexpected payment status: ${result.paymentIntent.status}`,
          );
        }
        // TODO: update user, membership, stripe_customer_id, etc
        onSubmit();
      } catch (err) {
        const error =
          typeof err === 'object' && err !== null && 'message' in err
            ? (err.message as string)
            : 'An unexpected error occurred.';
        addError('payment', error);
      }
    },
    [email, user, onSubmit, addError],
  );

  useEffect(() => {
    setLoading(true);
    const elements = stripe.elements({
      clientSecret: token,
      locale: 'en',
      appearance: {
        theme: 'flat',
      },
      loader: 'always',
    });
    const linkAuthElement = elements.create('linkAuthentication', {
      defaultValues: { email },
    });
    linkAuthElement.mount(linkAuthenticationRef.current!);
    linkAuthElement.on('change', ({ value: { email: v } }) => {
      setEmail(v);
    });
    const paymentElement = elements.create('payment', {
      defaultValues: {
        billingDetails: {
          name: [user?.firstName, user?.lastName].filter(Boolean).join(' '),
          email: user?.email ?? '',
          phone: user?.phone ?? '',
          address: {
            line1: user?.address?.split('\n')[0] ?? '',
            line2: user?.address?.split('\n')[1] ?? '',
            city: user?.city ?? '',
            state: user?.state ?? '',
            postal_code: user?.postalCode ?? '',
          },
        },
      },
      layout: 'tabs',
    } satisfies StripePaymentElementOptions);
    paymentElement.mount(paymentRef.current!);
    elementsRef.current = elements;
    Promise.all([
      waitForElement(linkAuthElement),
      waitForElement(paymentElement),
    ]).then(() => {
      setLoading(false);
    });

    return () => {
      linkAuthElement.unmount();
      paymentElement.unmount();
    };
  }, [token]); // eslint-disable-line react-hooks/exhaustive-deps

  if (!user) return <Redirect to={Paths.Home} />;

  return (
    <Block as="form" onSubmit={handleSubmit}>
      <Row>
        <Column>
          <div ref={linkAuthenticationRef} />
          <div ref={paymentRef} />
        </Column>
      </Row>
      <Actions sizes={[6, 6]}>
        {!loading && (
          <Button type="submit">
            <Icon name="cart-check-fill" /> Purchase
          </Button>
        )}
      </Actions>
    </Block>
  );
};

export default StripeForm;
