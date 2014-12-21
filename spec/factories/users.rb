# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  last_name              :string(255)
#  first_name             :string(255)
#  address                :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  postal_code            :string(255)
#  phone                  :integer
#  email                  :string(255)      default(""), not null
#  username               :string(255)      default(""), not null
#  member_since           :integer
#  created_at             :datetime
#  updated_at             :datetime
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

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
      u.memberships << FactoryGirl.create(:membership, user_id: u.id, type: %w(Individual Family).sample)
    end
    trait :admin do
      after :create do |u|
        u.current_membership.update_attribute(:privileges, u.current_membership.privileges + ['admin'])
      end
    end
    trait :family do
      after :create do |u|
        u.current_membership.update_attribute(:type, 'Family')
      end
    end
    trait :relative do
      after :create do |u|
        u.current_membership.update_attribute(:type, 'Relative')
      end
    end
    trait :executive_board do
      after :create do |u|
        u.current_membership.update_attribute(:privileges, u.current_membership.privileges + ['executive_board'])
      end
    end
    trait :at_large_board do
      after :create do |u|
        u.current_membership.update_attribute(:privileges, u.current_membership.privileges + ['at_large_board'])
      end
    end
    trait :no_membership do |u|
      u.memberships = []
    end
  end
end
