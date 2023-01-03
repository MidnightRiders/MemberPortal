FactoryBot.define do
  factory :club do
    name { FFaker::Address.city + ' SC' }
    abbrv { name.gsub(/\W/, '').upcase[0, [2, 3].sample] }
    primary_color { FFaker::Color.hex_code }
    secondary_color { FFaker::Color.hex_code }
    accent_color { FFaker::Color.hex_code }
    conference { %w(east west).sample }
    api_id { FFaker::Random.rand(0..9999) }

    trait :ne do
      abbrv { 'NE' }
      name { 'New England Revolution' }
    end
  end
end
