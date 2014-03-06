class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.belongs_to :home_team, class: 'Club', foreign_key: 'club_id'
      t.belongs_to :away_team, class: 'Club', foreign_key: 'club_id'
      t.datetime :kickoff
      t.string :location
      t.integer :home_goals, limit: 2
      t.integer :away_goals, limit: 2

      t.timestamps
    end
    add_index :matches, [:home_team_id, :away_team_id]
    add_index :matches, :home_team_id
    add_index :matches, :away_team_id
  end
end
