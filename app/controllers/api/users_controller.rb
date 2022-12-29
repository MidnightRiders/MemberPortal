class Api::UsersController < ApiController
  load_and_authorize_resource except: %i[current]

  def current
    user = current_user.as_json
      &.transform_keys { _1.camelize(:lower) }
      &.tap { _1[:isCurrentUser] = current_user.current_member? }
    render json: { user: user }, status: current_user.nil? ? :unauthorized : :ok
  end

  def show; end

  def index; end
end
