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
  homeGoals: number | null;
  homeTeam: Team;
  awayGoals: number | null;
  awayTeam: Team;
}

export const revsOpponent = (match: Match): Team =>
  [match.homeTeam, match.awayTeam].find(({ abbrv }) => abbrv !== 'NE')!;
