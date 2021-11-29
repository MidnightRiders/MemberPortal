FactoryBot.define do
  factory :player do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    club_id { Club.all.sample.try(:id) || FactoryBot.create(:club).id }
    position { Player::POSITIONS.to_a.sample[0] }
    number { (Random.rand * 98).to_i + 1 }
  end
end
