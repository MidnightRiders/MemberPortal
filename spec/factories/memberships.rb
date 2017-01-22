FactoryGirl.define do
  factory :membership do
    user { FactoryGirl.build(:user) }
    year { Date.current.year }
    info { { override: Membership.where("privileges::jsonb ? 'admin' AND year = :year", year: Date.current.year).first.user.id } }
    type :Individual

    trait :family do
      type :Family
    end

    trait :relative do
      type :Relative
      family_id { FactoryGirl.create(:membership, :family).id }
    end
  end
end
