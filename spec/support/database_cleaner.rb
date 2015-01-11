RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    Rails.application.load_seed
    create_admin
    Warden.test_mode!
  end

  config.around(:each) do |example|
    create_admin unless User.find_by(username: 'admin')
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:each) do
    Warden.test_reset!
  end

  def create_admin
    admin = User.create(first_name: 'Admin', last_name: 'User', email: 'admin@test.com', username: 'admin', password: 'admin_password')
    (1995..Date.current.year).each do |yr|
      admin_membership = Membership.new(year: yr, type: 'Individual', info: { override: admin.id }, privileges: ['admin'], user_id: admin.id)
      admin_membership.save validate: false
    end
  end

end