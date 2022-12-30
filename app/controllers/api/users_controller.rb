class Api::UsersController < ApiController
  load_and_authorize_resource except: %i[current]

  def current
    render json: { user: current_user&.as_json(api: false) }, status: current_user.nil? ? :unauthorized : :ok
  end

  def show; end

  def index; end
end
