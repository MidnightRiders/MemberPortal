# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :club do
    name 'New York Red Bulls'
    conference %w(east west).sample
    primary_color 'c5003e'
    secondary_color '002554'
    accent_color 'ffc72c'
    abbrv 'NY'
  end
  factory :revs, class: Club do
    name 'New England Revolution'
    conference 'east'
    primary_color '0c2340'
    secondary_color 'c8102e'
    accent_color 'ffffff'
    abbrv 'NE'
  end
end
