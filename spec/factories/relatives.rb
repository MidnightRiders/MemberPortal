FactoryGirl.define do
  factory :relative do
    year { Date.current.year }
    family_id { FactoryGirl.create(:membership, :family, :paid_for).id }

    trait :confirmed do
      user { FactoryGirl.build(:user) }
    end

    trait :pending do
      info { { pending_approval: true, email: FFaker::Internet.email } }
    end
  end
end
