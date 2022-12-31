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
    admin = User.find_or_create_by(first_name: 'Admin', last_name: 'User', email: 'admin@test.com', username: 'admin') do |u|
      u.password = 'admin_password'
    end
    (1995..Date.current.year).each do |yr|
      admin_membership = Membership.find_or_initialize_by(year: yr, type: 'Individual', user_id: admin.id) do |m|
        m.privileges = %w(admin)
        m.info = { override: admin.id }
      end
      admin_membership.save validate: false
    end
  end

end
