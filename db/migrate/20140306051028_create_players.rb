class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.integer :club_id
      t.string :position

      t.timestamps
    end
    add_index :players, :club_id
  end
end
