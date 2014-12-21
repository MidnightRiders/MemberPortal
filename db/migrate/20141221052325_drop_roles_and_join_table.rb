class DropRolesAndJoinTable < ActiveRecord::Migration
  def up
    drop_table :roles
    drop_table :membership_roles
  end

  def down

    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    add_index :roles, :name, unique: true

    create_table :membership_roles do |t|
      t.references :membership, :role
      t.timestamps
    end
    add_index :membership_roles, [:membership_id, :role_id]
    add_index :membership_roles, :membership_id

  end
end
