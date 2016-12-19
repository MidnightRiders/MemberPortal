class Api::V1::SessionsController < Api::V1::BaseController
  def create
    user = User.find_by(username: params[:username])
    if user.present? && user.valid_password?(params[:password])
      session = user.sessions.create(requesting_ip: request.remote_ip)
      respond_to do |format|
        format.json { render json: session, include: %w(), status: :ok }
      end
    else
      head :unauthorized
    end
  end

  def destroy
    session = Api::V1::Session.includes(:user).find_by(auth_token: params[:id])
    if session.present?
      if session.user.username == params[:username]
        session.destroy!
        head :ok
      else
        head :unauthorized
      end
    else
      head :not_found
    end
  end
end
