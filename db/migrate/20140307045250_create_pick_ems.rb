class CreatePickEms < ActiveRecord::Migration
  def change
    create_table :pick_ems do |t|
      t.references :match, index: true
      t.references :user, index: true
      t.integer :result, limit: 1

      t.timestamps
    end
    add_index :pick_ems, [:match_id, :user_id], unique: true
  end
end
