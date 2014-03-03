# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    type_id 1
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
  end
end
