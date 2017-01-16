# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  year       :integer
#  info       :hstore
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

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
