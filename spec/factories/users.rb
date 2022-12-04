FactoryBot.define do
  factory :user do
    transient do
      with_membership { true }
    end

    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    username { "#{first_name}#{last_name}".gsub(/\W/, '') }
    address { FFaker::AddressUS.street_address }
    city { FFaker::AddressUS.city }
    state { FFaker::AddressUS.state_abbr }
    postal_code { FFaker::AddressUS.zip_code }
    country { FFaker::AddressUS.country('US') }
    phone { FFaker::PhoneNumber.phone_number }
    email { FFaker::Internet.email }
    member_since { (Random.rand * (Date.today.year - 1995)).to_i + 1995 }
    password { FFaker::Lorem.characters(Random.rand * 12 + 8) }

    trait :without_membership do
      with_membership { false }
    end

    after :create do |u, evaluator|
      FactoryBot.create(:membership, user_id: u.id, type: %w(Individual Family).sample) if evaluator.with_membership
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
      memberships { [] }
    end
  end
end
