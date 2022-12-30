import type { JSX } from 'preact';
import { useCallback } from 'preact/hooks';
import { Link } from 'wouter-preact';

import SignIn from '~routes/SignIn';
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

  return (
    <>
      <div>
        <h1>
          <a href="/">Midnight Riders</a>
        </h1>
        <button type="button">
          <span>Menu</span>
        </button>
      </div>
      <nav>
        <ul>
          <li>
            <button type="button">
              <i class="fa-solid fa-external-link fa-fw" />
              Sites
            </button>
            <ul>
              <li>
                <a href="http://MidnightRiders.com" target="_blank">
                  <i class="fa-solid fa-link fa-fw" />
                  Riders Website
                </a>
              </li>
              <li>
                <a href="http://midnightriders.com/shop" target="_blank">
                  <i class="fa-solid fa-shopping-cart fa-fw" />
                  Shop
                </a>
              </li>
              <li>
                <label>Social</label>
              </li>
              <li>
                <button type="button">
                  <i class="fa-brands fa-facebook fa-fw" />
                  Facebook
                </button>
                <ul>
                  <li>
                    <a
                      href="https://www.facebook.com/groups/MidnightRiders2018/"
                      target="_blank"
                    >
                      Facebook Group
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://facebook.com/MidnightRiders"
                      target="_blank"
                    >
                      Facebook Page
                    </a>
                  </li>
                </ul>
              </li>
              <li>
                <a href="http://twitter.com/MidnightRiders" target="_blank">
                  <i class="fa-brands fa-twitter fa-fw" />
                  Twitter
                </a>
              </li>
              <li>
                <label>Other</label>
              </li>
              <li>
                <a href="http://revolutionsoccer.net" target="_blank">
                  <i class="fa-regular fa-bookmark fa-fw" />
                  Revolution Website
                </a>
              </li>
              <li>
                <button type="button">
                  <i class="fa-solid fa-beer fa-fw" />
                  Partner Pubs
                </button>
                <ul>
                  <li>
                    <a href="http://bansheeboston.com" target="_blank">
                      The Banshee
                      <small>Dorchester, MA</small>
                    </a>
                  </li>
                  <li>
                    <a href="http://parlorsportsbar.com" target="_blank">
                      Parlor Sports
                      <small>Somerville, MA</small>
                    </a>
                  </li>
                  <li>
                    <a href="http://www.the-rumbleseat.com/" target="_blank">
                      The Rumbleseat
                      <small>Chicopee, MA</small>
                    </a>
                  </li>
                  <li>
                    <a href="http://www.bisoncounty.com/" target="_blank">
                      Bison County
                      <small>Waltham, MA</small>
                    </a>
                  </li>
                </ul>
              </li>
              <li>
                <button type="button">
                  <i class="fa-regular fa-star fa-fw" />
                  Other Partners
                </button>
                <ul>
                  <li>
                    <a href="http://www.awaydaysfootball.com/" target="_blank">
                      Away Days
                      <small>Quincy, MA</small>
                      {user /* && user.current_member */ && (
                        <>
                          <br />
                          15% Off Code:
                          <code>RIDERSOVERHERE2017</code>
                        </>
                      )}
                    </a>
                  </li>
                  <li>
                    <a href="http://www.risingtidebrewing.com" target="_blank">
                      Rising Tide Brewing
                      <small>Portland, ME</small>
                    </a>
                  </li>
                  <li>
                    <a href="http://topshelfcookies.com/" target="_blank">
                      Top Shelf Cookies
                      <small>Quincy, MA</small>
                      {user /* && user.current_member */ && (
                        <>
                          <br />
                          15% Off Code:
                          <code>RIDERS2017</code>
                        </>
                      )}
                    </a>
                  </li>
                </ul>
              </li>
              <li>
                <button type="button">
                  <i class="fa-brands fa-reddit fa-fw" />
                  Reddit
                </button>
                <ul>
                  <li>
                    <a
                      href="http://reddit.com/r/newenglandrevolution"
                      target="_blank"
                    >
                      Revolution Subreddit
                    </a>
                  </li>
                  <li>
                    <a href="http://reddit.com/r/mls" target="_blank">
                      MLS Subreddit
                    </a>
                  </li>
                </ul>
              </li>
            </ul>
            {user && (
              <li>
                <a href="/home">
                  <i class="fa-solid fa-home fa-fw" />
                  Home
                </a>
              </li>
            )}
            <li>
              <a href="/faq" title="FAQ">
                <i class="fa-solid fa-circle-question fa-fw" />
                FAQ
              </a>
            </li>
            <li>
              <a href="/contact" title="Contact Us">
                <i class="fa-regular fa-comment fa-fw fa-flip-horizontal" />
                Contact Us
              </a>
            </li>
          </li>
          {user ? (
            <>
              {true /* current_user.current_member? */ && (
                <>
                  <li>
                    <a href="/matches">
                      <i class="fa-regular fa-calendar fa-fw" />
                      Matches
                    </a>
                  </li>
                  <li>
                    <button type="button">
                      <i class="fa-solid fa-trophy fa-fw" />
                      Games
                    </button>
                    <ul>
                      <li>
                        <a href="/matches">
                          <i class="fa-solid fa-check fa-fw" />
                          RevGuess/Pick &rapos;Em
                        </a>
                      </li>
                      <li>
                        <a href="/standings">
                          <i class="fa-solid fa-trophy fa-fw" />
                          Standings
                        </a>
                      </li>
                      <li>
                        <a
                          href="https://fantasy.mlssoccer.com/#classic/leagues/771/join/AMN4KR2S"
                          target="_blank"
                        >
                          <i class="fa-solid fa-users fa-fw" />
                          MLS Fantasy
                        </a>
                      </li>
                      <li>
                        <label>Other Fantasy</label>
                      </li>
                      <li>
                        <a
                          href="http://fantasy.premierleague.com/my-leagues/290319/join/?autojoin-code=1206043-290319"
                          target="_blank"
                        >
                          <i class="fa-solid fa-users fa-fw" />
                          EPL Fantasy
                        </a>
                      </li>
                      {true /* current_user.privilege?('admin') || current_user.privilege?('executive_board') */ && (
                        <>
                          <li>
                            <label>Admin</label>
                          </li>
                          <li>
                            <a href="/motm">
                              <i class="fa-solid fa-list-ol fa-fw" />
                              MotY Rankings
                            </a>
                          </li>
                        </>
                      )}
                    </ul>
                  </li>
                </>
              )}
              <li>
                <a href={`/users/${user.id}/edit`}>
                  <i class="fa-regular fa-user fa-fw" />
                  My Account
                </a>
              </li>
              {true && (
                /* user.current_member? && (current_user.privilege?('admin') || current_user.privilege?('executive_board')) */ <>
                  <li>
                    <button type="button" title="Admin">
                      <i class="fa-solid fa-bolt fa-fw" />
                      Admin
                    </button>
                    <ul>
                      {true /* can? :view, :users */ && (
                        <li>
                          <a href="/users">
                            <i class="fa-solid fa-users fa-fw" />
                            Users
                          </a>
                        </li>
                      )}
                      {true /* can? :transactions, :static_page */ && (
                        <li>
                          <a href="/transactions">
                            <i class="fa-regular fa-dollar fa-fw" />
                            Transactions
                          </a>
                        </li>
                      )}
                      <li></li>
                      <li>
                        <a href="/clubs">
                          <i class="fa-solid fa-shield fa-fw" />
                          Clubs
                        </a>
                      </li>
                      {true /* can? :view, :players */ && (
                        <li>
                          <a href="/players">
                            <i class="fa-solid fa-list fa-fw" />
                            Players
                          </a>
                        </li>
                      )}
                    </ul>
                  </li>
                </>
              )}
              <li>
                <button type="button" title="Sign Out" onClick={handleLogOut}>
                  <i class="fa-solid fa-power-off fa-fw" />
                  Sign Out
                </button>
              </li>
            </>
          ) : (
            <>
              <li>
                <a href="/users/sign_up">
                  <i class="fa-solid fa-pencil-square fa-fw" />
                  Sign Up
                </a>
              </li>
              <li>
                <Link href={SignIn.path}>
                  <i class="fa-solid fa-sign-in fa-fw" />
                  Sign In
                </Link>
              </li>
            </>
          )}
        </ul>
      </nav>
    </>
  );
};

export default Navigation;
