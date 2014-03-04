class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, :role
      t.timestamps
    end
    add_index :user_roles, [:user_id, :role_id]
    add_index :user_roles, :user_id
  end
end
