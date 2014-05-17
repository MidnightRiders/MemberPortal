class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, index: true
      t.integer :year
      t.hstore :info

      t.timestamps
    end
    add_hstore_index :memberships, :info
  end
end
