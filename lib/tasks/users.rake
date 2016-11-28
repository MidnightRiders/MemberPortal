namespace :users do
  task update_spree_roles: :environment do
    admin_role = Spree::Role.find_or_create_by(name: :admin)
    User.admin.find_each do |user|
      user.spree_roles = user.spree_roles - admin_role
    end
    User.with_privileges(:admin).find_each do |user|
      user.spree_roles << admin_role
    end
  end
end
