# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    name %w(individual family).sample
  end
  factory :admin_role, class: Role do
    name 'admin'
  end
  factory :executive_board_role, class: Role do
    name 'executive_board'
  end
  factory :at_large_board_role, class: Role do
    name 'executive_board'
  end
end
