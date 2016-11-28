class AddSpreeFieldsToCustomUserTable < ActiveRecord::Migration
  def up
    add_column "users", :spree_api_key, :string, :limit => 48
    add_column "users", :ship_address_id, :integer
    add_column "users", :bill_address_id, :integer
  end
end
