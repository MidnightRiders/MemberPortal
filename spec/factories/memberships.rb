FactoryBot.define do
  factory :membership do
    user { FactoryBot.build(:user) }
    year { Date.current.year }
    info { { override: User.find_by(username: 'admin').id } }
    type :Individual

    trait :family do
      type :Family
    end

    trait :relative do
      type :Relative
      family_id { FactoryBot.create(:membership, :family).id }
    end
  end
end
