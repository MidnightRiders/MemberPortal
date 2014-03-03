class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_filter :authenticate_user!
  before_filter :check_permissions, only: [:index]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /home
  def home

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username)
    end

    def check_permissions
      authorize! :view, resource
    end
end
