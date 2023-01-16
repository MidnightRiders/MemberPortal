enum Paths {
  Home = '/',
  Login = '/login',
  Register = '/sign-up',
  SignIn = '/sign-in',
  SignUp = '/sign-up',
  ResetPassword = '/reset-password',
  FAQ = '/faq',
  ContactUs = '/contact-us',

  Matches = '/matches',
  Match = '/match/:id',
  Standings = '/standings',
  MotMs = '/motms',
  CurrentUser = '/user',
  Users = '/users',
  User = '/user/:id',
  UserCurrentMembership = '/user/:userId/membership',
  UserMembership = '/user/:userId/membership/:id',
  Transactions = '/transactions',
  Polls = '/admin/polls',
  Poll = '/admin/poll/:id',
  Clubs = '/admin/clubs',
  Club = '/admin/club/:id',
  Players = '/admin/players',
  Player = '/admin/player/:id',
}

export default Paths;

interface PathTo {
  (path: Paths, id: string | number): string;
  (path: Paths, params: Record<string, string | number>): string;
}

export const pathTo: PathTo = (
  path: Paths,
  params: string | number | Record<string, string | number>,
) => {
  const pathWithParams = Object.entries(
    typeof params === 'object' ? params : { id: params },
  ).reduce<string>(
    (p, [key, value]) => p.replace(`:${key}`, value.toString()),
    path,
  );

  return pathWithParams;
};
