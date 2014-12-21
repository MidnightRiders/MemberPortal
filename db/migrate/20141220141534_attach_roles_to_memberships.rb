class AttachRolesToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :roles, :json
    Membership.all.each do |membership|
      roles = Role.where(id: MembershipRole.select('role_id').where({ membership_id: membership.id })).map(&:name)
      puts roles.join(', ')
      membership.update_attribute(:roles, roles)
      puts "#{membership.user.username}: #{membership.roles.join(', ')}"
    end
  end

  def down
    remove_column :memberships, :roles
  end
end
