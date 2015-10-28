class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user
      t.references :post, polymorphic: true
      t.integer :value, :smallint

      t.timestamps
    end
    
    add_index :votes, [ :user_id, :post_id, :post_type ], unique: true
  end
end
