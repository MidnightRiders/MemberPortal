class Api::UsersController < ApiController
  load_and_authorize_resource except: %i[current create]
  skip_before_action :authenticate_user!, only: %i[create]

  def current
    @user = current_user
    render json: { error: 'Not logged in' }, status: :unauthorized and return unless @user.present?

    render 'show'
  end

  def show; end

  def index; end

  def create
    user = User.new(user_params)
    # skip confirmation; UI allows user to show password if needed
    user.password_confirmation = user_params[:password]
    user.save!
    @current_user = user
    @user = current_user
    sign_in current_user, store: false
    render 'show', status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: e.message, errors: user.errors.transform_keys { _1.camelize(:lower) } }, status: :bad_request
  end

  def update
    @user.update!(user_params)
    render 'show'
  end

  def destroy
    @user.destroy!
    render json: {}, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(
    :email,
      :password,
      :username,
      :first_name,
      :last_name,
      :address,
      :city,
      :state,
      :postal_code,
      :country,
    )
  end
end
