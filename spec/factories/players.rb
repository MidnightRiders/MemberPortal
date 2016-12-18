# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  club_id    :integer
#  position   :string(255)
#  created_at :datetime
#  updated_at :datetime
#  number     :integer
#  active     :boolean          default(TRUE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    club_id { Club.all.sample.try(:id) || FactoryGirl.create(:club).id }
    position { Player::POSITIONS.to_a.sample[0] }
    number { (Random.rand * 98).to_i + 1 }
  end
end
