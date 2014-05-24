class MembershipsController < ApplicationController
  load_and_authorize_resource
  before_action :get_user

  def index
    @memberships = @user.memberships
  end
  def show

  end
  def new
    @membership = @user.memberships.new
  end
  def create

  end
  def edit

  end
  def update

  end
  def destroy

  end
  private
    def get_user
      @user = User.find_by(username: params[:user_id])
    end
    def get_membership
      @membership = Membership.find(params[:id])
    end
end
