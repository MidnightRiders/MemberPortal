class CreateMotMs < ActiveRecord::Migration
  def change
    create_table :mot_ms do |t|
      t.integer :user_id
      t.integer :match_id
      t.integer :first_id
      t.integer :second_id
      t.integer :third_id

      t.timestamps
    end
    add_index :mot_ms, [:user_id, :match_id], unique: true
  end
end
