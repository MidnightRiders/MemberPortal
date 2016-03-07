class DropClubs < ActiveRecord::Migration
  def up
    remove_attachment :clubs, :crest

    drop_table :clubs
  end

  def down
    create_table :clubs do |t|
      t.string   :name
      t.string   :conference
      t.integer  :primary_color
      t.integer  :secondary_color
      t.integer  :accent_color
      t.string   :abbrv
      t.boolean  :active

      t.timestamps
    end

    add_attachment :clubs, :crest

    add_index :clubs, [:conference], name: 'index_clubs_on_conference', using: :btree

    clubs = JSON.load(Rails.root.join('lib/assets/clubs.json'))
  end
end
