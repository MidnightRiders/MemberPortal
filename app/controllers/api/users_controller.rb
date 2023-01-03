class Api::UsersController < ApiController
  load_and_authorize_resource except: %i[current]

  def current
    @user = current_user
    render json: { error: 'Not logged in' }, status: :unauthorized and return unless @user.present?

    render 'show'
  end

  def show; end

  def index; end
end
