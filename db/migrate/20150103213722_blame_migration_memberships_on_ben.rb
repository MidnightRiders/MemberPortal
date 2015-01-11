class BlameMigrationMembershipsOnBen < ActiveRecord::Migration
  def up
    ben = User.unscoped.find_by(username: 'bensaufley')
    Membership.unscoped.where(info: nil).each do |membership|
      membership.update_attribute(:info, { override: ben.id })
    end
    Membership.unscoped.where("info -> 'override' = ?", 'migration').each do |membership|
      membership.info_will_change!
      membership.info['override'] = ben.id
      membership.save validate: false
    end
  end

  def down
    Membership.unscoped.where("info -> 'override' = ?", User.find_by(username: 'bensaufley').id.to_s).each do |membership|
      membership.info_will_change!
      membership.info['override'] = 'migration'
      membership.save validate: false
    end
  end
end
