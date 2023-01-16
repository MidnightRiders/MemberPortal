import type { JSX } from 'preact';
import { useCallback, useMemo } from 'preact/hooks';

import type { Node } from '~shared/components/Navigation/NavNode';
import { useAuthCtx } from '~shared/contexts/auth';
import { useLogOut } from '~shared/contexts/auth/hooks';
import Paths from '~shared/paths';

import { useConfirm } from '../../contexts/confirmation';

const useNav = () => {
  const { user } = useAuthCtx();
  const confirm = useConfirm();
  const logOut = useLogOut();

  const handleLogOut = useCallback<JSX.GenericEventHandler<HTMLButtonElement>>(
    async (e) => {
      e.preventDefault();
      if (!(await confirm('Are you sure you wish to sign out?'))) return;

      logOut();
    },
    [confirm, logOut],
  );

  return useMemo<Node[]>(
    () => [
      {
        icon: 'box-arrow-up-right',
        content: 'Sites',
        children: [
          {
            content: 'Riders',
            type: 'group',
            children: [
              {
                href: 'https://midnightriders.com',
                external: true,
                icon: 'link',
                content: 'Riders Website',
              },
              {
                href: 'https://midnightriders.com/shop',
                external: true,
                icon: 'cart',
                content: 'Shop',
              },
            ],
          },
          { divider: true },
          {
            content: 'Social',
            type: 'group',
            children: [
              {
                icon: 'facebook',
                content: 'Facebook',
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
                icon: 'instagram',
                content: 'Instagram',
              },
              {
                href: 'https://twitter.com/MidnightRiders',
                external: true,
                icon: 'twitter',
                content: 'Twitter',
              },
              {
                href: 'https://tifosi.social/@MidnightRiders',
                external: true,
                icon: 'mastodon',
                content: 'Mastodon',
              },
              {
                icon: 'reddit',
                content: 'Reddit',
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
        icon: 'house-fill',
        content: 'Home',
        collapse: true,
        href: Paths.Home,
      },
      {
        href: Paths.FAQ,
        icon: 'question-circle-fill',
        content: 'FAQ',
        collapse: true,
      },
      {
        href: Paths.ContactUs,
        icon: 'chat-fill',
        content: 'Contact Us',
        collapse: true,
      },
      user
        ? [
            true /* current_user.current_member? */ && [
              {
                icon: 'calendar3',
                content: 'Matches',
                gap: true,
                href: Paths.Matches,
              },
              {
                icon: 'trophy-fill',
                content: 'Games',
                children: [
                  {
                    href: Paths.Matches,
                    icon: 'check',
                    content: 'RevGuess/Pick ’Em',
                  },
                  {
                    href: Paths.Standings,
                    icon: 'trophy-fill',
                    content: 'Standings',
                  },
                  {
                    href: 'https://fantasy.mlssoccer.com/#classic/leagues/771/join/AMN4KR2S',
                    external: true,
                    icon: 'clipboard-data-fill',
                    content: 'MLS Fantasy',
                  },
                  {
                    content: 'Other Fantasy',
                    type: 'group',
                    children: [
                      {
                        href: 'http://fantasy.premierleague.com/my-leagues/290319/join/?autojoin-code=1206043-290319',
                        external: true,
                        icon: 'clipboard-data-fill',
                        content: 'EPL Fantasy',
                      },
                    ],
                  },
                  true /* current_user.privilege?('admin') || current_user.privilege?('executive_board') */ && {
                    content: 'Admin',
                    type: 'group',
                    children: [
                      {
                        href: Paths.MotMs,
                        icon: 'list-ol',
                        content: 'MotY Rankings',
                      },
                    ],
                  },
                ],
              },
              {
                href: Paths.User,
                icon: 'person-fill',
                content: 'My Account',
              },
              true /* user.current_member? && (current_user.privilege?('admin') || current_user.privilege?('executive_board')) */ && [
                {
                  icon: 'lightning-fill',
                  content: 'Admin',
                  collapse: true,

                  children: [
                    {
                      content: 'Management',
                      icon: 'pencil-fill',
                      children: [
                        true /* can? :view, :users */ && {
                          href: Paths.Users,
                          icon: 'people-fill',
                          content: 'Users',
                        },
                        true /* can? :transactions, :static_page */ && {
                          href: Paths.Transactions,
                          icon: 'currency-dollar',
                          content: 'Transactions',
                        },
                      ],
                    },
                    true /* can? :manage, Poll */ && [
                      { divider: true },
                      {
                        href: Paths.Polls,
                        icon: 'bar-chart-line-fill',
                        content: 'Polls',
                      },
                    ],
                    { divider: true },
                    {
                      content: 'Portal',
                      icon: 'database-fill',
                      children: [
                        {
                          href: Paths.Clubs,
                          icon: 'shield-fill',
                          content: 'Clubs',
                        },
                        true /* can? :view, :players */ && {
                          href: Paths.Players,
                          icon: 'people-fill',
                          content: 'Players',
                        },
                      ],
                    },
                  ],
                },
              ],
            ],
            {
              onClick: handleLogOut,
              collapse: true,
              icon: 'power',
              content: 'Sign Out',
            },
          ]
        : [
            {
              href: Paths.SignUp,
              gap: true,
              icon: 'pencil-square',
              content: 'Sign Up',
            },
            {
              href: Paths.SignIn,
              icon: 'box-arrow-in-right',
              content: 'Sign In',
            },
          ],
    ],
    [handleLogOut, user],
  );
};

export default useNav;
