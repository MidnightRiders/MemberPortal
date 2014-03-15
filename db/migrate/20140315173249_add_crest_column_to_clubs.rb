class AddCrestColumnToClubs < ActiveRecord::Migration
  def up
    add_attachment :clubs, :crest
  end
  def down
    remove_attachment :clubs, :crest
  end
end
