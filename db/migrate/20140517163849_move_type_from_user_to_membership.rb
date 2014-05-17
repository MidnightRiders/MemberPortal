class MoveTypeFromUserToMembership < ActiveRecord::Migration
  def change
    create_table :membership_roles do |t|
      t.references :membership, :role
      t.timestamps
    end
    add_index :membership_roles, [:membership_id, :role_id]
    add_index :membership_roles, :membership_id
  end
end
