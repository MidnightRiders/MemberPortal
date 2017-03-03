FactoryGirl.define do
  factory :membership do
    transient do
      paid_for false
    end

    user { FactoryGirl.build(:user) }
    year { Date.current.year }

    type :Individual

    trait :family do
      type :Family
    end

    trait :paid_for do
      info { {} }
      stripe_charge_id { StripeHelper.charge_id }
      paid_for true
    end

    trait :relative do
      type :Relative
      family_id { FactoryGirl.create(:membership, :family).id }
    end

    after(:build) do |membership, evaluator|
      membership.info = { override: User.find_by(username: 'admin').id } unless evaluator.paid_for
    end
  end
end
