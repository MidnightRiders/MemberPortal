FactoryGirl.define do
  factory :club do
    name { Faker::Address.city + ' FC' }
    abbrv { name.gsub(/\W/,'').upcase[0,[2,3].sample] }
    primary_color { (Random.rand * 'ffffff'.to_i(16)).to_i.to_s(16) }
    secondary_color { (Random.rand * 'ffffff'.to_i(16)).to_i.to_s(16) }
    accent_color { (Random.rand * 'ffffff'.to_i(16)).to_i.to_s(16) }
    conference { %w(east west).sample }
    trait :ne do
      abbrv 'NE'
      name 'New England Revolution'
    end
  end
end