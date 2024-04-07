import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import Link from '~shared/components/Link';
import { useAuthCtx } from '~shared/contexts/auth';
import makeRoute from '~shared/makeRoute';
import Paths, { pathTo } from '~shared/paths';

const FAQ = makeRoute(Paths.FAQ, () => {
  const { user } = useAuthCtx();

  return (
    <Row>
      <Column size={3}>
        <h2 class="white">FAQ</h2>
      </Column>
      <Column size={9}>
        <Block>
          <dl>
            <dt id="security">Is my information secure?</dt>
            <dd>
              <p>
                <strong>Yes.</strong> The Member Portal uses SSL to connect with your browser, which means the
                information you share with us is securely encrypted. In addition,{' '}
                <em>we do not store any of your financial information on our servers.</em> Instead, your information is
                passed on to{' '}
                <Link href="https://stripe.com" external target="_blank" rel="noopener noreferrer">
                  Stripe
                </Link>{' '}
                a secure payment provider that manages credit cards and hands us a token by which to connect your
                account to their data. The only retrievable information Stripe maintains is the last four digits and
                expiration of your card, for your own reference, and tokens by which we can securely make charges. You
                will receive a receipt from us and from Stripe for every transaction.
              </p>
            </dd>
            <dt id="signup">How do I become a member?</dt>
            <dd>
              <p>
                Simple! Just go to the <Link href={Paths.Home}>home page</Link> and click “Sign Up.” Once you’ve created
                an account, you can purchase a membership in one quick step. That’s it! Once you’ve done that, you’re a
                Midnight Rider, and you’ll have access to all of the benefits of being one, including Supporters Lot
                parking, merchandise discounts, and full access to the Member Portal.
              </p>
            </dd>
            <dt id="username">I’m already a member. What’s my username?</dt>
            <dd>
              <p>
                If you signed up in person at a Riders event this year or last, you were sent a welcome email with your
                login information around the time you signed up. If you’re not the <em>primary accountholder</em> of a
                Family membership, you do not have an account yet.{' '}
                <strong>
                  <Link href="#relatives">See below</Link>
                </strong>{' '}
                for more information about family members. The <strong>default username</strong> is your first name and
                last name with no capital letters and no spaces. For example, Jay Heaps would be
                <strong>jayheaps</strong>.
              </p>
            </dd>
            <dt id="password">What’s my password?</dt>
            <dd>
              <p>
                If you signed up in person at a Riders event this year or last, you were sent a welcome email with your
                login information. If you know you have an account but don’t remember your password,{' '}
                <strong>
                  <Link href={Paths.ResetPassword}>click here</Link>
                </strong>{' '}
                to request a password reset email. If you’ve never logged in,
              </p>
            </dd>
            <dt id="relatives">Can family members have their own logins?</dt>
            <dd>
              <p>
                Yes! Once you’ve purchased a Family membership, you may add family members to the membership by inviting
                them from{' '}
                {user?.isCurrentMember ? (
                  <>
                    your{' '}
                    <Link
                      href={pathTo(Paths.UserCurrentMembership, {
                        userId: user.id,
                      })}
                    >
                      Membership page
                    </Link>
                    .
                  </>
                ) : (
                  <>the page that details your current membership (accessible from the Home page).</>
                )}{' '}
                Your family member will create a new user, or use an existing one, and accept your invitation from their
                Home screen.
              </p>
            </dd>
            <dt id="merchandise">Do I need to sign in to buy merchandise?</dt>
            <dd>
              <p>
                Not at this time. Just visit{' '}
                <Link external href="http://midnightriders.com/shop" target="_blank" rel="noopener noreferrer">
                  the shop page
                </Link>{' '}
                to get all your Riders merch.
              </p>
            </dd>
            <dt id="other">I still can’t log in.</dt>
            <dd>
              <p>
                If you think you should have an account, and you’ve tried the above solutions (check your username –{' '}
                <Link href="#username">see above</Link>, try{' '}
                <Link href={Paths.ResetPassword}>resetting your password</Link>) and you still can’t log in,{' '}
                <Link href="mailto:member-portal-support@midnightriders.com?subject=Member%20Portal%20Access">
                  send us an email
                </Link>
                .
              </p>
            </dd>
          </dl>
        </Block>
      </Column>
    </Row>
  );
});

export default FAQ;
