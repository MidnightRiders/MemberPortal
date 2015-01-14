class AddTypeToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :type, :string
    rename_column :memberships, :roles, :privileges

    Membership.unscoped.all.each do |membership|
      type = (membership.privileges & Membership::TYPES.map(&:downcase)).first.try(:titleize)
      privileges = membership.privileges - Membership::TYPES.map(&:downcase)
      if type
        membership.update_attribute(:type, type)
        membership.update_attribute(:privileges, privileges)
      else
        logger.error 'Type empty!'
        logger.error membership
      end
    end
  end

  def down
    Membership.unscoped.all.each do |membership|
      membership.privileges << membership.type.downcase if membership.type.present?
    end

    rename_column :memberships, :privileges, :roles
    remove_column :memberships, :type
  end
end
