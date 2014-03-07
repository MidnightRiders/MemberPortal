class RevGuess < ActiveRecord::Base
  belongs_to :match
  belongs_to :user

  validates :user, :match, :home_goals, :away_goals, presence: true
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'
end
