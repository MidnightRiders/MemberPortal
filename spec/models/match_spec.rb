require 'spec_helper'

describe Match do
  # Capybara overwrites the +all+ matcher without this +include+
  include RSpec::Matchers.clone

  describe 'score' do
    skip 'returns # - # for completed games'
    skip 'returns – for incomplete games'
  end

  describe 'complete?' do
    skip 'returns whether scoring information has been filled in'
  end

  describe 'result' do
    skip 'returns :home for games where home team won'
    skip 'returns :away for games where away team won'
    skip 'returns :draw for games where neither team won'
    skip 'returns nil if game not complete'
  end

  describe 'winner' do
    skip 'returns Club for home_team if home team won'
    skip 'returns Club for away_team if away team won'
    skip 'returns nil if not complete'
    skip 'returns nil if draw'
  end

  describe 'loser' do
    skip 'returns Club for home_team if home team lost'
    skip 'returns Club for away_team if away team lost'
    skip 'returns nil if not complete'
    skip 'returns nil if draw'
  end

  describe 'voteable?' do
    skip 'returns true if MotM voting may begin'
    skip 'returns false if MotM voting may not begin'
  end

  describe 'in_future?' do
    skip 'returns whether the kickoff is in the future'
  end

  describe 'in_past?' do
    skip 'returns inverse of in_future?'
  end

  describe 'teams' do
    skip 'returns an Array with [home_team, away_team]'
  end

  describe 'update_games' do
    skip 'updates counters for Games'
  end

  describe 'check_for_season' do
    skip 'sets season to kickoff year if season not present'
  end

  describe 'scopes' do
    skip 'all_seasons'
    skip 'with_clubs'
    skip 'completed'
    skip 'upcoming'
  end

  describe 'class methods' do
    describe 'import_ics' do
      let(:ics) { File.read(Rails.root.join('spec', 'fixtures', 'files', '2017-schedule-truncated.ics')) }

      it 'adds new Matches' do
        expect { Match.import_ics(ics) }.to change(Match, :count).by(38)
      end

      it 'only adds new Matches' do
        Match.import_ics(ics)

        Match.all.sample(15).each(&:destroy)

        expect { Match.import_ics(ics) }.to change(Match, :count).by(15)
      end

      it 'returns an array of Matches' do
        expect(Match.import_ics(ics)).to all(be_a(Match))
      end

      it 'creates the right number of Matches per team' do
        Match.import_ics(ics)

        expect(Club.where(abbrv: %w(RSL POR SKC ATL MIN NY NE SEA TOR CLB)).map(&:matches).map(&:length)).to all(eq(4))
        expect(Club.where(abbrv: %w(VAN SJ NYC ORL PHI MTL CHI COL DC DAL HOU LA)).map(&:matches).map(&:length)).to all(eq(3))
      end

      it 'doesn\'t return unchanged Matches' do
        Match.import_ics(ics)

        Match.all.sample(15).each(&:destroy)

        expect(Match.import_ics(ics)).to all(be_a(Match))
      end
    end

    describe 'from_ics_event' do
      let(:event) { Icalendar::Event.parse(File.read(Rails.root.join('spec', 'fixtures', 'files', 'event.ics'))).first }
      let(:non_match) { Icalendar::Event.parse(File.read(Rails.root.join('spec', 'fixtures', 'files', 'non-match-event.ics'))).first }

      it 'raises for non-match events' do
        expect { Match.from_ics_event(non_match) }.to raise_error('Not enough teams')
      end

      it 'creates a new Match if not present' do
        expect { Match.from_ics_event(event) }.to change(Match, :count).by(1)
      end

      it 'updates an existing Match' do
        match = Match.from_ics_event(event)
        match.update_attribute(:kickoff, match.kickoff - 4.hours)

        expect { Match.from_ics_event(event) }.to change { match.reload.kickoff }
      end

      it 'returns nil for an identical Match' do
        Match.from_ics_event(event)

        expect(Match.from_ics_event(event)).to be_nil
      end
    end

    describe 'teams_from_event_summary' do
      it 'returns exact matches' do
        clubs = Club.all.sample(2)
        summary = clubs.map(&:name).join(' vs. ')

        expect(Match.teams_from_event_summary(summary)).to eq(clubs)
      end

      it 'returns fuzzy matches' do
        clubs = [Club.find_by(abbrv: 'MTL'), Club.find_by(abbrv: 'NY')]
        summary = 'Montreal Impact vs. Red Bull New York'

        expect(Match.teams_from_event_summary(summary)).to eq(clubs)
      end

      it 'picks correct NY teams' do
        clubs = [Club.find_by(abbrv: 'NYC'), Club.find_by(abbrv: 'NY')]

        expect(Match.teams_from_event_summary('New York City vs. New York')).to eq(clubs)
        expect(Match.teams_from_event_summary('NYCFC vs. Red Bulls')).to eq(clubs)
      end
    end
  end
end
