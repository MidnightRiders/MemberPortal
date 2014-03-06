class AddUidToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :uid, :string
    add_index :matches, :uid
  end
end
