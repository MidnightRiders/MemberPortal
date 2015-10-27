class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user, index: true
      t.references :post, polymorphic: true, index: { unique: true }
      t.integer :value, :smallint

      t.timestamps
    end
  end
end
