import type { JSX } from 'preact';
import { useCallback, useMemo } from 'preact/hooks';
import { Link } from 'wouter-preact';

import logo from '~shared/assets/logo.png';
import { useAuthCtx } from '~shared/contexts/auth';
import { useLogOut } from '~shared/contexts/auth/hooks';

const Navigation = () => {
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

  const items = useMemo(
    (): Readonly<unknown[]> => [
      {
        key: 'sites',
        label: (
          <>
            <i class="fa-solid fa-external-link fa-fw" /> Sites{' '}
            <i class="fa-solid fa-chevron-down fa-fw" />
          </>
        ),
        children: [
          {
            label: 'Riders',
            type: 'group' as const,
            children: [
              {
                label: (
                  <a
                    href="https://midnightriders.com"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-solid fa-link fa-fw" /> Riders Website
                  </a>
                ),
                key: 'riders-website',
              },
              {
                label: (
                  <a
                    href="https://midnightriders.com/shop"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-solid fa-shopping-cart fa-fw" /> Shop
                  </a>
                ),
                key: 'shop',
              },
            ],
          },
          { type: 'divider' as const },
          {
            type: 'group' as const,
            label: 'Social',
            children: [
              {
                label: 'Facebook',
                key: 'facebook',
                icon: <i class="fa-brands fa-facebook fa-fw" />,
                children: [
                  {
                    label: (
                      <a
                        href="https://facebook.com/groups/MidnightRiders2023/"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Facebook Group
                      </a>
                    ),
                    key: 'facebook-group',
                  },
                  {
                    label: (
                      <a
                        href="https://facebook.com/MidnightRiders"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Facebook Page
                      </a>
                    ),
                    key: 'facebook-page',
                  },
                ],
              },
              {
                label: (
                  <a
                    href="https://instagram.com/midnightriders1995"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-brands fa-instagram fa-fw" /> Instagram
                  </a>
                ),
                key: 'instagram',
              },
              {
                label: (
                  <a
                    href="https://twitter.com/MidnightRiders"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-brands fa-twitter fa-fw" /> Twitter
                  </a>
                ),
                key: 'twitter',
              },
              {
                label: (
                  <a
                    href="https://tifosi.social/@MidnightRiders"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-brands fa-mastodon fa-fw" /> Mastodon
                  </a>
                ),
                key: 'mastodon',
              },
              {
                label: 'Reddit',
                key: 'reddit',
                icon: <i class="fa-brands fa-reddit fa-fw" />,
                children: [
                  {
                    label: (
                      <a
                        href="https://reddit.com/r/newenglandrevolution"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Revolution Subreddit
                      </a>
                    ),
                    key: 'revs-subreddit',
                  },
                  {
                    label: (
                      <a
                        href="https://reddit.com/r/mls"
                        target="_blank"
                        rel="noreferrer"
                      >
                        MLS Subreddit
                      </a>
                    ),
                    key: 'mls-subreddit',
                  },
                ],
              },
            ],
          },
          { type: 'divider' as const },
          {
            type: 'group' as const,
            label: 'Other',
            children: [
              {
                label: (
                  <a
                    href="https://revolutionsoccer.net"
                    target="_blank"
                    rel="noreferrer"
                  >
                    <i class="fa-solid fa-bookmark fa-fw" /> Revolution Website
                  </a>
                ),
                key: 'revs-website',
              },
              {
                label: 'Partner Pubs',
                key: 'partner-pubs',
                icon: <i class="fa-solid fa-beer fa-fw" />,
                children: [
                  {
                    label: (
                      <a
                        href="https://bansheeboston.com"
                        target="_blank"
                        rel="noreferrer"
                      >
                        The Banshee <small>Dorchester, MA</small>
                      </a>
                    ),
                    key: 'the-banshee',
                  },
                  {
                    label: (
                      <a
                        href="https://parlorsportsbar.com"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Parlor Sports <small>Somerville, MA</small>
                      </a>
                    ),
                    key: 'parlor-sports',
                  },
                  {
                    label: (
                      <a
                        href="https://www.the-rumbleseat.com/"
                        target="_blank"
                        rel="noreferrer"
                      >
                        The Rumbleseat <small>Chicopee, MA</small>
                      </a>
                    ),
                    key: 'the-rumbleseat',
                  },
                  {
                    label: (
                      <a
                        href="https://www.bisoncounty.com/"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Bison County <small>Waltham, MA</small>
                      </a>
                    ),
                    key: 'bison-county',
                  },
                ],
              },
              {
                label: 'Other Partners',
                key: 'other-partners',
                icon: <i class="fa-solid fa-star fa-fw" />,
                children: [
                  {
                    label: (
                      <a
                        href="https://www.awaydaysfootball.com/"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Away Days <small>Quincy, MA</small>
                        {user?.isCurrentMember && (
                          <>
                            {/* TODO: dynamically load and style multiline */}
                            <br />
                            15% Off Code:
                            <code>RIDERSOVERHERE2017</code>
                          </>
                        )}
                      </a>
                    ),
                    key: 'away-days',
                  },
                  {
                    label: (
                      <a
                        href="https://www.risingtidebrewing.com"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Rising Tide Brewing <small>Portland, ME</small>
                      </a>
                    ),
                    key: 'rising-tide-brewing',
                  },
                  {
                    label: (
                      <a
                        href="https://topshelfcookies.com/"
                        target="_blank"
                        rel="noreferrer"
                      >
                        Top Shelf Cookies <small>Quincy, MA</small>
                        {user?.isCurrentMember && (
                          <>
                            {/* TODO: dynamically load and style multiline */}
                            <br />
                            15% Off Code:
                            <code>RIDERS2017</code>
                          </>
                        )}
                      </a>
                    ),
                    key: 'top-shelf-cookies',
                  },
                ],
              },
            ],
          },
        ],
      },
      ...(user
        ? [
            {
              label: 'Home',
              key: 'home',
              icon: <i class="fa-solid fa-home fa-fw" />,
            },
          ]
        : []),
      {
        label: 'FAQ',
        key: 'faq',
        icon: <i class="fa-solid fa-circle-question fa-fw" />,
      },
      {
        label: 'Contact Us',
        key: 'contact-us',
        icon: <i class="fa-regular fa-comment fa-fw fa-flip-horizontal" />,
      },
      ...(user
        ? [
            ...(true /* current_user.current_member? */
              ? [
                  {
                    label: 'Matches',
                    key: 'matches',
                    icon: <i class="fa-regular fa-calendar fa-fw" />,
                  },
                  {
                    label: (
                      <>
                        <i class="fa-solid fa-trophy fa-fw" /> Games{' '}
                        <i class="fa-solid fa-chevron-down fa-fw" />
                      </>
                    ),
                    key: 'games',
                    children: [
                      {
                        label: 'Members',
                        type: 'group' as const,
                        children: [
                          {
                            label: 'RevGuess/Pick ’Em',
                            key: 'rev-guess-pick-rapos-em',
                            icon: <i class="fa-solid fa-check fa-fw" />,
                          },
                          {
                            label: 'Standings',
                            key: 'standings',
                            icon: <i class="fa-solid fa-trophy fa-fw" />,
                          },
                          {
                            label: 'MLS Fantasy',
                            key: 'mls-fantasy',
                            icon: <i class="fa-solid fa-users fa-fw" />,
                          },
                        ],
                      },
                      {
                        type: 'group' as const,
                        label: 'Other Fantasy',
                        children: [
                          {
                            label: 'EPL Fantasy',
                            key: 'epl-fantasy',
                            icon: <i class="fa-solid fa-users fa-fw" />,
                          },
                        ],
                      },
                      ...(true /* current_user.privilege?('admin') || current_user.privilege?('executive_board') */
                        ? [
                            {
                              type: 'group' as const,
                              label: 'Admin',
                              children: [
                                {
                                  label: 'MotY Rankings',
                                  key: 'mot-y-rankings',
                                  icon: <i class="fa-solid fa-list-ol fa-fw" />,
                                },
                              ],
                            },
                          ]
                        : []),
                    ],
                  },
                ]
              : []),
            {
              label: 'My Account',
              key: 'my-account',
              icon: <i class="fa-regular fa-user fa-fw" />,
            },
            ...(true /* user.current_member? && (current_user.privilege?('admin') || current_user.privilege?('executive_board')) */
              ? [
                  {
                    label: (
                      <>
                        <i class="fa-solid fa-bolt fa-fw" /> Admin{' '}
                        <i class="fa-solid fa-chevron-down fa-fw" />
                      </>
                    ),
                    key: 'admin',
                    children: [
                      {
                        label: 'Management',
                        type: 'group' as const,
                        children: [
                          ...(true /* can? :view, :users */
                            ? [
                                {
                                  label: 'Users',
                                  key: 'users',
                                  icon: <i class="fa-solid fa-users fa-fw" />,
                                },
                              ]
                            : []),
                          ...(true /* can? :transactions, :static_page */
                            ? [
                                {
                                  label: 'Transactions',
                                  key: 'transactions',
                                  icon: (
                                    <i class="fa-regular fa-dollar fa-fw" />
                                  ),
                                },
                              ]
                            : []),
                        ],
                      },
                      ...(true /* can? :manage, Poll */
                        ? [
                            { type: 'divider' as const },
                            {
                              label: 'Polls',
                              key: 'polls',
                              icon: <i class="fa-solid fa-poll fa-fw" />,
                            },
                          ]
                        : []),
                      { type: 'divider' as const },
                      {
                        label: 'Portal',
                        type: 'group' as const,
                        children: [
                          {
                            label: 'Clubs',
                            key: 'clubs',
                            icon: <i class="fa-solid fa-shield fa-fw" />,
                          },
                          ...(true /* can? :view, :players */
                            ? [
                                {
                                  label: 'Players',
                                  key: 'players',
                                  icon: <i class="fa-solid fa-list fa-fw" />,
                                },
                              ]
                            : []),
                        ],
                      },
                    ],
                  },
                ]
              : []),
            {
              label: 'Sign Out',
              key: 'sign-out',
              onClick: handleLogOut,
              icon: <i class="fa-solid fa-power-off fa-fw" />,
            },
          ]
        : [
            {
              label: 'Sign Up',
              key: 'sign-up',
              icon: <i class="fa-solid fa-pencil-square fa-fw" />,
            },
            {
              label: (
                <Link href="/sign-in">
                  <i class="fa-solid fa-sign-in fa-fw" /> Sign In
                </Link>
              ),
              key: 'sign-in',
            },
          ]),
    ],
    [user, handleLogOut],
  );

  // TODO: navbar
  return null;
};

export default Navigation;
