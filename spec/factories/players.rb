# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    club_id { Club.all.sample.id }
    position { Player::POSITIONS.to_a.sample[0] }
    number { (Random.rand * 98).to_i + 1 }
  end
end
