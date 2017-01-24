FactoryGirl.define do
  factory :membership do
    user { FactoryGirl.build(:user) }
    year { Date.current.year }
    info { { override: User.find_by(username: 'admin').id } }
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
