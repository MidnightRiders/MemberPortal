export interface Team {
  abbrv: string;
  name: string;
  crest: {
    thumb: string;
  };
}

export interface Match {
  id: number;
  kickoff: Date;
  location: string;
  teams: [Team, Team];
}

export const revsOpponent = (match: Match) =>
  match.teams.find(({ abbrv }) => abbrv !== 'NE');

export const matchLink = (match: Match) => `/matches/${match.id}`;
