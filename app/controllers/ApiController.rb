class ApiController < ActionController::API
  protect_from_forgery unless: -> { request.headers['Authorization'].present? }
  before_action :authenticate_user!

  private
  # Returns +Club+ and caches associated +Matches+.
  def revs
    @revs ||= Club.includes(:home_matches, :away_matches).find_by(abbrv: 'NE')
  end

  def authenticate_user!
    jwt = request.headers['Authorization']&.split&.last
    render json: { error: 'Unauthorized' }, status: :unauthorized unless jwt.present?

    payload, _ = JWT.decode jwt, ENV.fetch('JWT_SECRET'), true, algorithm: 'HS512'
    user = User.find_by(id: payload['id'])
    sign_in user, store: false if user
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
