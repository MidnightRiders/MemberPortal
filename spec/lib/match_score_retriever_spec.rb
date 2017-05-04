require 'spec_helper'
require 'match_score_retriever'
require 'json'
require 'ostruct'

RSpec.describe MatchScoreRetriever, :vcr do
  describe 'constructor' do
    it 'creates a Nokogiri object for reference from an HTTPS get' do
      importer = MatchScoreRetriever.new(Date.new(2017, 4, 24))

      expect(importer.instance_variable_get('@html')).to be_a(Nokogiri::HTML::Document)
      expect(importer.instance_variable_get('@html').content).not_to eq('')
    end
  end

  describe 'match_info_for' do
    let(:importer) { MatchScoreRetriever.new(Date.new(2017, 4, 24)) }

    it 'returns nil if no Match is found with same teams' do
      different_match = fake_match(
        home_team: { abbrv: 'NE' },
        away_team: { abbrv: 'NY' },
        kickoff: DateTime.new(2017, 04, 25, 19, 30)
      )
      expect(importer.match_info_for(different_match)).to be_nil
    end

    it 'calls ErrorNotifier and returns nil if a match is found for the wrong date' do
      different_date_match = fake_match(
        home_team: { abbrv: 'SEA' },
        away_team: { abbrv: 'NE' },
        kickoff: DateTime.new(2017, 04, 30, 19, 30)
      )

      expect(ErrorNotifier).to receive(:notify)
      expect(importer.match_info_for(different_date_match)).to be_nil
    end

    it 'returns a Hash if a match is found' do
      match = fake_match(
        home_team: { abbrv: 'NY' },
        away_team: { abbrv: 'CHI' },
        kickoff: DateTime.new(2017, 04, 29, 19, 30)
      )

      expect(importer.match_info_for(match)).to eq(home_goals: 2, away_goals: 1)
    end
  end

  private

  def fake_match(hash)
    JSON.parse(hash.to_json, object_class: OpenStruct)
  end
end
