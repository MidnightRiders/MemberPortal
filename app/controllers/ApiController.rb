class ApiController < ActionController::API
  before_action :authenticate_user!

  private
  # Returns +Club+ and caches associated +Matches+.
  def revs
    @revs ||= Club.includes(:home_matches, :away_matches).find_by(abbrv: 'NE')
  end

  def authenticate_user!
    if current_user
      sign_in current_user
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized and return false
    end
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized and return false
  end

  def render(**args)
    (args[:json] ||= {})[:jwt] = current_user&.jwt
    super(**args)
  end

  def current_user
    return @current_user if defined?(@current_user)

    jwt = request.headers['Authorization']&.split&.last
    return @current_user = nil unless jwt.present?

    payload, _ = JWT.decode jwt, ENV.fetch('JWT_SECRET'), true, algorithm: 'HS512'
    @current_user = User.find_by(id: payload['id'])
  end
end
