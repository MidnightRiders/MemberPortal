class AddResultsToGames < ActiveRecord::Migration
  def up
    add_column :pick_ems, :correct, :boolean, null: true
    add_column :rev_guesses, :score, :integer, null: true

    Match.where.not(home_goals: nil, away_goals: nil).each do |match|
      match.update_games
    end
  end

  def down
    remove_column :pick_ems, :correct
    remove_column :rev_guesses, :score
  end
end
