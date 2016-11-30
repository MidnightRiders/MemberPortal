RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    Rails.application.load_seed
    Capybara.match = :prefer_exact
    create_admin
    Warden.test_mode!
  end

  config.before(:each) do
    Rails.cache.clear
    create_admin unless User.find_by(username: 'admin')
    if RSpec.current_example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    # TODO: Find out why open_transactions ever gets below 0
    # See issue #3428
    if ActiveRecord::Base.connection.open_transactions < 0
      ActiveRecord::Base.connection.increment_open_transactions
    end

    DatabaseCleaner.start
    reset_spree_preferences
  end

  config.after(:each) do
    # wait_for_ajax sometimes fails so we should clean db first to get rid of false failed specs
    DatabaseCleaner.clean

    # Ensure js requests finish processing before advancing to the next test
    wait_for_ajax if RSpec.current_example.metadata[:js]
  end

  def create_admin
    admin = User.create(first_name: 'Admin', last_name: 'User', email: 'admin@test.com', username: 'admin', password: 'admin_password')
    (1995..Date.current.year).each do |yr|
      admin_membership = Membership.new(year: yr, type: 'Individual', info: { override: admin.id }, privileges: ['admin'], user_id: admin.id)
      admin_membership.save validate: false
    end
  end
end
