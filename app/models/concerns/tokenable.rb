module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_auth_token
  end

  protected

  def generate_auth_token
    self.auth_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(auth_token: random_token)
    end
    self.expires_at = 1.week.from_now
  end
end
