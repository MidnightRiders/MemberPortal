# == Schema Information
#
# Table name: mot_ms
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  match_id   :integer
#  first_id   :integer
#  second_id  :integer
#  third_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :mot_m do
    match_id { (Match.where('kickoff BETWEEN [?,?]', Time.now - 2.weeks, Time.now - 2.hours).order('kickoff ASC').last || FactoryGirl.create(:match, kickoff: Time.now - 2.hours)).id }
    user_id { (User.first || FactoryGirl.create(:user)).id }
    first_id { (Player.all.sample || FactoryGirl.create(:player)).id }
    second_id { (Player.where('id != ?', first_id).sample || FactoryGirl.create(:player)).id }
    third_id { (Player.where('id NOT IN (?)', [first_id,second_id]).sample || FactoryGirl.create(:player)).id }
  end
end
