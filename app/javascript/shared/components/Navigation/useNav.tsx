import type { JSX } from 'preact';
import { useCallback, useMemo } from 'preact/hooks';

import { useAuthCtx } from '~shared/contexts/auth';
import type { Node } from '~shared/components/Navigation/NavNode';
import { useLogOut } from '~shared/contexts/auth/hooks';
import Paths from '~shared/paths';

import styles from './styles.module.css';

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
            <i class="fa-solid fa-external-link fa-fw" /> Sites
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
                    <i class="fa-solid fa-link fa-fw" /> Riders Website
                  </>
                ),
              },
              {
                href: 'https://midnightriders.com/shop',
                external: true,
                content: (
                  <>
                    <i class="fa-solid fa-shopping-cart fa-fw" /> Shop
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
                    <i class="fa-brands fa-facebook fa-fw" /> Facebook
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
                    <i class="fa-brands fa-instagram fa-fw" /> Instagram
                  </>
                ),
              },
              {
                href: 'https://twitter.com/MidnightRiders',
                external: true,
                content: (
                  <>
                    <i class="fa-brands fa-twitter fa-fw" /> Twitter
                  </>
                ),
              },
              {
                href: 'https://tifosi.social/@MidnightRiders',
                external: true,
                content: (
                  <>
                    <i class="fa-brands fa-mastodon fa-fw" /> Mastodon
                  </>
                ),
              },
              {
                content: (
                  <>
                    <i class="fa-brands fa-reddit fa-fw" /> Reddit
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
            <i class="fa-solid fa-home fa-fw" />
            <span class={styles.iconOnly}>Home</span>
          </>
        ),
        href: Paths.Home,
      },
      {
        href: Paths.FAQ,
        content: (
          <>
            <i class="fa-solid fa-circle-question fa-fw" />
            <span class={styles.iconOnly}>FAQ</span>
          </>
        ),
      },
      {
        href: Paths.ContactUs,
        content: (
          <>
            <i class="fa-regular fa-comment fa-fw fa-flip-horizontal" />
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
                    <i class="fa-regular fa-calendar fa-fw" /> Matches
                  </>
                ),
                gap: true,
                href: Paths.Matches,
              },
              {
                content: (
                  <>
                    <i class="fa-solid fa-trophy fa-fw" /> Games
                  </>
                ),
                children: [
                  {
                    href: Paths.Matches,
                    content: (
                      <>
                        <i class="fa-solid fa-check fa-fw" /> RevGuess/Pick ’Em
                      </>
                    ),
                  },
                  {
                    href: Paths.Standings,
                    content: (
                      <>
                        <i class="fa-solid fa-trophy fa-fw" /> Standings
                      </>
                    ),
                  },
                  {
                    href: 'https://fantasy.mlssoccer.com/#classic/leagues/771/join/AMN4KR2S',
                    external: true,
                    content: (
                      <>
                        <i class="fa-solid fa-users fa-fw" /> MLS Fantasy
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
                            <i class="fa-solid fa-users fa-fw" /> EPL Fantasy
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
                            <i class="fa-solid fa-list-ol fa-fw" /> MotY
                            Rankings
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
                    <i class="fa-regular fa-user fa-fw" /> My Account
                  </>
                ),
              },
              true /* user.current_member? && (current_user.privilege?('admin') || current_user.privilege?('executive_board')) */ && [
                {
                  content: (
                    <>
                      <i class="fa-solid fa-bolt fa-fw" />
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
                              <i class="fa-solid fa-users fa-fw" /> Users
                            </>
                          ),
                        },
                        true /* can? :transactions, :static_page */ && {
                          href: Paths.Transactions,
                          content: (
                            <>
                              <i class="fa-regular fa-dollar fa-fw" />{' '}
                              Transactions
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
                            <i class="fa-solid fa-poll fa-fw" /> Polls
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
                              <i class="fa-solid fa-shield fa-fw" /> Clubs
                            </>
                          ),
                        },
                        true /* can? :view, :players */ && {
                          href: Paths.Players,
                          content: (
                            <>
                              <i class="fa-solid fa-list fa-fw" /> Players
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
              content: (
                <>
                  <i class="fa-solid fa-power-off fa-fw" />
                  Sign Out
                </>
              ),
            },
          ]
        : [
            {
              href: Paths.SignUp,
              content: (
                <>
                  <i class="fa-solid fa-pencil-square fa-fw" /> Sign Up
                </>
              ),
            },
            {
              href: Paths.SignIn,
              content: (
                <>
                  <i class="fa-solid fa-sign-in fa-fw" /> Sign In
                </>
              ),
            },
          ],
    ],
    [user],
  );
};

export default useNav;
