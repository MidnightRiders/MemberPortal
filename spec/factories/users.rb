# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name 'Matt'
    last_name 'Reis'
    username 'mattreis'
    address '1600 Pennsylvania Ave'
    city 'Boston'
    state 'MA'
    postal_code '02135'
    phone '207-867-5309'
    email 'test@test.com'
    member_since 2010
    password 'Password1$'
    after :create do |u|
      u.roles << create(:role)
    end
    trait :admin do
      after :create do |u|
        u.roles << create(:admin_role)
      end
    end
    trait :executive_board do
      after :create do |u|
        u.roles << create(:executive_board_role)
      end
    end
    trait :at_large_board do
      after :create do |u|
        u.roles << create(:at_large_board_role)
      end
    end
  end
end