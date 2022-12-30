# frozen_string_literal: true

class Api::SessionsController < ApiController
  skip_before_action :authenticate_user!, only: %i[create]

  def create
    user = User.find_by(username: params[:username])

    if user&.valid_password?(params[:password])
      sign_in user
      @current_user = user
      render json: { user: user.as_json(api: true), jwt: user.jwt }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def destroy
    sign_out current_user
    @current_user = nil
    render body: nil, status: :no_content
  end
end
