FactoryBot.define do
  factory :mot_m do
    match_id { (Match.where(kickoff: Time.now - 2.weeks..Time.now - 2.hours).order(kickoff: :asc).last || FactoryBot.create(:match, kickoff: Time.now - 2.hours)).id }
    user_id { (User.first || FactoryBot.create(:user)).id }
    first_id { (Player.all.sample || FactoryBot.create(:player)).id }
    second_id { (Player.where('id != ?', first_id).sample || FactoryBot.create(:player)).id }
    third_id { (Player.where('id NOT IN (?)', [first_id, second_id]).sample || FactoryBot.create(:player)).id }
  end
end
