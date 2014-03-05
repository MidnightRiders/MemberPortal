class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :name
      t.string :conference
      t.integer :primary_color, limit: 4
      t.integer :secondary_color, limit: 4
      t.integer :accent_color, limit: 4
      t.string :abbrv

      t.timestamps
    end
    add_index :clubs, :conference
  end
end
