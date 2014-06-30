FactoryGirl.define do
  factory :mot_m do
    match_id { (Match.where('kickoff < ?', Time.now).first || FactoryGirl.create(:match, kickoff: Time.now - 2.hours)).id }
    user_id { (User.first || FactoryGirl.create(:user)).id }
    first_id { (Player.all.sample || FactoryGirl.create(:player)).id }
    second_id { (Player.where('id != ?', first_id).sample || FactoryGirl.create(:player)).id }
    third_id { (Player.where('id NOT IN (?)', [first_id,second_id]).sample || FactoryGirl.create(:player)).id }
  end
end