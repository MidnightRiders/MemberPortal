class AddFamilyIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :family_id, :integer
  end
end
