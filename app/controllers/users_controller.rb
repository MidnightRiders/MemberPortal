class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
    @users = User.all.order('last_name ASC, first_name ASC')
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /home
  def home

  end

  def import
    if params[:file]
      User.import(params[:file])
      redirect_to users_path, notice: 'Users imported.'
    else
      redirect_to users_path, alert: 'No file was selected'
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username)
    end
end
