class ApiController < ActionController::API
  before_action :underscore_params!
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordInvalid, with: :show_ar_errors
  rescue_from ActionController::ParameterMissing, with: :show_missing_params
  rescue_from ApiError, with: :show_api_error

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
    Rails.logger.info("inside current_user")
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

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
  end

  def show_ar_errors(err)
    render json: {
      message: err.message,
      errors: user.errors.transform_keys { _1.camelize(:lower) },
      jwt: current_user&.jwt,
    }, status: :bad_request
  end

  # @param [ActionController::ParameterMissing] err
  def show_missing_params(err)
    render json: {
      message: err.message,
      missingKeys: err.keys.map { _1.camelize(:lower) },
      jwt: current_user&.jwt,
    }, status: :bad_request
  end

  # @param [ApiError] err
  def show_api_error(err)
    render json: {
      message: err.message,
      jwt: current_user&.jwt,
    }, status: err.status
  end
end
