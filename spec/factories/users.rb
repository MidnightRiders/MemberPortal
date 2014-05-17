# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { "#{first_name}#{last_name}".gsub(/\W/,'') }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.postcode }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    member_since { (Random.rand*(Date.today.year-1995)).to_i+1995 }
    password { Faker::Lorem.characters(Random.rand*12 + 8) }
    after :create do |u|
      u.roles << Role.find_or_create_by(name: %w(individual family).sample)
      u.memberships << FactoryGirl.create(:membership, user_id: u.id)
    end
    trait :admin do
      after :create do |u|
        u.roles << Role.find_or_create_by(name: 'admin')
      end
    end
    trait :executive_board do
      after :create do |u|
        u.roles << Role.find_or_create_by(name: 'executive_board')
      end
    end
    trait :at_large_board do
      after :create do |u|
        u.roles << Role.find_or_create_by(name: 'at_large_board')
      end
    end
    trait :no_membership do |u|
      u.memberships = []
    end
  end
end