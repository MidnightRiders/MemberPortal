class AddTypeToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :type, :string
    rename_column :memberships, :roles, :privileges

    Membership.all.each do |membership|
      membership.type = (membership.privileges & Membership::TYPES.map(&:downcase)).first.titleize
      membership.privileges = membership.privileges - Membership::TYPES.map(&:downcase)
      membership.save
    end
  end

  def down
    Membership.all.each do |membership|
      membership.privileges << membership.type.downcase if membership.type.present?
    end

    rename_column :memberships, :privileges, :roles
    remove_column :memberships, :type
  end
end
