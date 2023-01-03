class ApiController < ActionController::API
  before_action :authenticate_user!

  private

  # Returns +Club+ and caches associated +Matches+.
  def revs
    @revs ||= Club.includes(:home_matches, :away_matches).find_by(abbrv: 'NE')
  end

  def authenticate_user!
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized and return false
    end

    old_current, new_current = current_user.current_sign_in_at, Time.now.utc
    current_user.last_sign_in_at = old_current || new_current
    current_user.current_sign_in_at = new_current
    current_user.save
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized and return false
  end

  def current_user
    return @current_user if defined?(@current_user)

    jwt = request.headers['Authorization']&.split&.last
    return @current_user = nil unless jwt.present?

    (payload, _, _) = JWT.decode jwt, ENV.fetch('JWT_SECRET'), true, algorithm: 'HS512'
    @current_user = User.find_by(id: payload['id'])
  end
  helper_method :current_user

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
  helper_method :current_ability
end
