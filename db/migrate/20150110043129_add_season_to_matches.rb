class AddSeasonToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :season, :integer

    Match.all.each do |match|
      match.update_attribute(:season, match.kickoff.year)
    end
  end
end
