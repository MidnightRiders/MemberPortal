class CreateRevGuesses < ActiveRecord::Migration
  def change
    create_table :rev_guesses do |t|
      t.references :match, index: true
      t.references :user, index: true
      t.integer :home_goals
      t.integer :away_goals
      t.string :comment

      t.timestamps
    end
    add_index :rev_guesses, [ :match_id, :user_id ], unique: true
  end
end
