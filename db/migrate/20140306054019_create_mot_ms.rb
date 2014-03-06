class CreateMotMs < ActiveRecord::Migration
  def change
    create_table :mot_ms do |t|
      t.string :user_id
      t.string :match_id
      t.string :first_id
      t.string :second_id
      t.string :third_id

      t.timestamps
    end
    add_index :mot_ms, [:user_id, :match_id], unique: true
  end
end
