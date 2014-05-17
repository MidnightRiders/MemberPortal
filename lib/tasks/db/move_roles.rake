namespace :db do
  task :move_roles => :environment do
    User.all.each do |user|
      if user.memberships.empty?
        user.memberships.create(year: Date.today.year, info: { override: 'migration'})
      end
    end
    Membership.all.each do |membership|
      membership.roles = membership.user.roles
    end
  end
end