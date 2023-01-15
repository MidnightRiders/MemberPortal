import type { JSX } from 'preact';
import { useCallback, useMemo } from 'preact/hooks';

import { useAuthCtx } from '~shared/contexts/auth';
import type { Node } from '~shared/components/Navigation/NavNode';
import { useLogOut } from '~shared/contexts/auth/hooks';
import Paths from '~shared/paths';

import styles from './styles.module.css';
import Icon from '../Icon';

const useNav = () => {
  const { user } = useAuthCtx();
  const logOut = useLogOut();

  const handleLogOut = useCallback<JSX.GenericEventHandler<HTMLButtonElement>>(
    (e) => {
      e.preventDefault();
      if (!confirm('Are you sure you wish to sign out?')) return;

      logOut();
    },
    [logOut],
  );

  return useMemo<Node[]>(
    () => [
      {
        content: (
          <>
            <Icon name="box-arrow-up-right" /> Sites
          </>
        ),
        children: [
          {
            content: 'Riders',
            type: 'group',
            children: [
              {
                href: 'https://midnightriders.com',
                external: true,
                content: (
                  <>
                    <Icon name="link" /> Riders Website
                  </>
                ),
              },
              {
                href: 'https://midnightriders.com/shop',
                external: true,
                content: (
                  <>
                    <Icon name="cart" /> Shop
                  </>
                ),
              },
            ],
          },
          { divider: true },
          {
            content: 'Social',
            type: 'group',
            children: [
              {
                content: (
                  <>
                    <Icon name="facebook" /> Facebook
                  </>
                ),
                children: [
                  {
                    href: 'https://facebook.com/groups/MidnightRiders2023/',
                    external: true,
                    content: 'Facebook Group',
                  },
                  {
                    href: 'https://facebook.com/MidnightRiders',
                    external: true,
                    content: 'Facebook Page',
                  },
                ],
              },
              {
                href: 'https://instagram.com/midnightriders1995',
                external: true,
                content: (
                  <>
                    <Icon name="instagram" /> Instagram
                  </>
                ),
              },
              {
                href: 'https://twitter.com/MidnightRiders',
                external: true,
                content: (
                  <>
                    <Icon name="twitter" /> Twitter
                  </>
                ),
              },
              {
                href: 'https://tifosi.social/@MidnightRiders',
                external: true,
                content: (
                  <>
                    <Icon name="mastodon" /> Mastodon
                  </>
                ),
              },
              {
                content: (
                  <>
                    <Icon name="reddit" /> Reddit
                  </>
                ),
                children: [
                  {
                    href: 'https://reddit.com/r/newenglandrevolution',
                    external: true,
                    content: 'Revolution Subreddit',
                  },
                  {
                    href: 'https://reddit.com/r/mls',
                    external: true,
                    content: 'MLS Subreddit',
                  },
                ],
              },
            ],
          },
          { divider: true },
          {
            content: 'Other',
            type: 'group',
            children: [
              {
                href: 'https://revolutionsoccer.net',
                external: true,
                content: 'Revolution Website',
              },
              {
                content: 'Partner Pubs',
                children: [
                  {
                    href: 'https://bansheeboston.com',
                    external: true,
                    content: (
                      <>
                        The Banshee <small>Dorchester, MA</small>
                      </>
                    ),
                  },
                  {
                    href: 'https://parlorsportsbar.com',
                    external: true,
                    content: (
                      <>
                        Parlor Sports <small>Somerville, MA</small>
                      </>
                    ),
                  },
                  {
                    href: 'https://www.the-rumbleseat.com/',
                    external: true,
                    content: (
                      <>
                        The Rumbleseat <small>Chicopee, MA</small>
                      </>
                    ),
                  },
                  {
                    href: 'https://www.bisoncounty.com/',
                    external: true,
                    content: (
                      <>
                        Bison County <small>Waltham, MA</small>
                      </>
                    ),
                  },
                ],
              },
              {
                content: 'Other Partners',
                children: [
                  {
                    href: 'https://www.awaydaysfootball.com/',
                    external: true,
                    content: (
                      <>
                        Away Days <small>Quincy, MA</small>
                        {user?.isCurrentMember && (
                          <>
                            {/* TODO: dynamically load and style multiline */}
                            <br />
                            15% Off Code:
                            <code>RIDERSOVERHERE2017</code>
                          </>
                        )}
                      </>
                    ),
                  },
                  {
                    href: 'https://www.risingtidebrewing.com',
                    external: true,
                    content: (
                      <>
                        Rising Tide Brewing <small>Portland, ME</small>
                      </>
                    ),
                  },
                  {
                    href: 'https://topshelfcookies.com/',
                    external: true,
                    content: (
                      <>
                        {' '}
                        Top Shelf Cookies <small>Quincy, MA</small>
                        {user?.isCurrentMember && (
                          <>
                            {/* TODO: dynamically load and style multiline */}
                            <br />
                            15% Off Code:
                            <code>RIDERS2017</code>
                          </>
                        )}
                      </>
                    ),
                  },
                ],
              },
            ],
          },
        ],
      },
      user && {
        content: (
          <>
            <Icon name="house-fill" />
            <span class={styles.iconOnly}>Home</span>
          </>
        ),
        href: Paths.Home,
      },
      {
        href: Paths.FAQ,
        content: (
          <>
            <Icon name="question-circle-fill" />
            <span class={styles.iconOnly}>FAQ</span>
          </>
        ),
      },
      {
        href: Paths.ContactUs,
        content: (
          <>
            <Icon name="chat-fill" />
            <span class={styles.iconOnly}>Contact Us</span>
          </>
        ),
      },
      user
        ? [
            true /* current_user.current_member? */ && [
              {
                content: (
                  <>
                    <Icon name="calendar" /> Matches
                  </>
                ),
                gap: true,
                href: Paths.Matches,
              },
              {
                content: (
                  <>
                    <Icon name="trophy" /> Games
                  </>
                ),
                children: [
                  {
                    href: Paths.Matches,
                    content: (
                      <>
                        <Icon name="check" /> RevGuess/Pick ’Em
                      </>
                    ),
                  },
                  {
                    href: Paths.Standings,
                    content: (
                      <>
                        <Icon name="trophy" /> Standings
                      </>
                    ),
                  },
                  {
                    href: 'https://fantasy.mlssoccer.com/#classic/leagues/771/join/AMN4KR2S',
                    external: true,
                    content: (
                      <>
                        <Icon name="people-fill" /> MLS Fantasy
                      </>
                    ),
                  },
                  {
                    content: 'Other Fantasy',
                    type: 'group',
                    children: [
                      {
                        href: 'http://fantasy.premierleague.com/my-leagues/290319/join/?autojoin-code=1206043-290319',
                        external: true,
                        content: (
                          <>
                            <Icon name="people-fill" /> EPL Fantasy
                          </>
                        ),
                      },
                    ],
                  },
                  true /* current_user.privilege?('admin') || current_user.privilege?('executive_board') */ && {
                    content: 'Admin',
                    type: 'group',
                    children: [
                      {
                        href: Paths.MotMs,
                        content: (
                          <>
                            <Icon name="list-ol" /> MotY Rankings
                          </>
                        ),
                      },
                    ],
                  },
                ],
              },
              {
                href: Paths.User,
                content: (
                  <>
                    <Icon name="person-fill" /> My Account
                  </>
                ),
              },
              true /* user.current_member? && (current_user.privilege?('admin') || current_user.privilege?('executive_board')) */ && [
                {
                  content: (
                    <>
                      <Icon name="lightning" />
                      <span class={styles.iconOnly}>Admin</span>
                    </>
                  ),

                  children: [
                    {
                      content: 'Management',
                      children: [
                        true /* can? :view, :users */ && {
                          href: Paths.Users,
                          content: (
                            <>
                              <Icon name="people-fill" /> Users
                            </>
                          ),
                        },
                        true /* can? :transactions, :static_page */ && {
                          href: Paths.Transactions,
                          content: (
                            <>
                              <Icon name="currency-dollar" /> Transactions
                            </>
                          ),
                        },
                      ],
                    },
                    true /* can? :manage, Poll */ && [
                      { divider: true },
                      {
                        href: Paths.Polls,
                        content: (
                          <>
                            <Icon name="bar-chart-line-fill" /> Polls
                          </>
                        ),
                      },
                    ],
                    { divider: true },
                    {
                      content: 'Portal',
                      children: [
                        {
                          href: Paths.Clubs,
                          content: (
                            <>
                              <Icon name="shield" /> Clubs
                            </>
                          ),
                        },
                        true /* can? :view, :players */ && {
                          href: Paths.Players,
                          content: (
                            <>
                              <Icon name="list" /> Players
                            </>
                          ),
                        },
                      ],
                    },
                  ],
                },
              ],
            ],
            {
              onClick: handleLogOut,
              title: 'Sign Out',
              content: (
                <>
                  <Icon name="power" />
                  <span class={styles.iconOnly}>Sign Out</span>
                </>
              ),
            },
          ]
        : [
            {
              href: Paths.SignUp,
              gap: true,
              content: (
                <>
                  <Icon name="pencil-square" /> Sign Up
                </>
              ),
            },
            {
              href: Paths.SignIn,
              content: (
                <>
                  <Icon name="box-arrow-in-right" /> Sign In
                </>
              ),
            },
          ],
    ],
    [user],
  );
};

export default useNav;
