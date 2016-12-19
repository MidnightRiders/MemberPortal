class Api::V1::Session < ActiveRecord::Base
  include Tokenable

  belongs_to :user, inverse_of: :sessions
  validates_associated :user

  after_save :limit_sessions

  def to_param
    self[:auth_token]
  end

  private

  def limit_sessions
    user_sessions = user.sessions.order(expires_at: :desc)
    while user_sessions.reload.size > User::SESSION_LIMIT
      user_sessions.last.destroy
    end
  end
end
