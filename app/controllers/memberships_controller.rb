# TODO: Flesh out Membership Controller for creation, modification, etc

# Controller for +Membership+ model.
class MembershipsController < ApplicationController
  load_and_authorize_resource
  before_action :get_user

  # GET /users/:user_id/memberships
  # GET /users/:user_id/memberships.json
  def in
    @memberships = @user.memberships
  end

  # GET /users/:user_id/memberships/1
  # GET /users/:user_id/memberships/1.json
  def show
  end

  # GET /users/:user_id/memberships/new
  def new
    privileges = @user.memberships.last.try(:privileges)
    year = Date.current.month > 10 ? Date.current.year + 1 : Date.current.year
    @membership = @user.memberships.new(year: year, privileges: privileges)
  end

  # GET /users/:user_id/memberships/1/edit
  def edit
  end

  # POST /users/:user_id/memberships
  # POST /users/:user_id/memberships.json
  def create
    # binding.pry
    @membership = @user.memberships.new(membership_params)

    respond_to do |format|
      if @membership.save
        format.html { redirect_to @user, notice: 'Membership was successfully created.' }
        format.json { render action: 'show', status: :created, location: @membership }
      else
        format.html { render action: 'new' }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/:user_id/memberships/1
  # PATCH/PUT /users/:user_id/memberships/1.json
  def update
    respond_to do |format|
      if @membership.update(club_params)
        format.html { redirect_to @membership, notice: 'Club was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/:user_id/memberships/1
  # DELETE /users/:user_id/memberships/1.json
  def destroy
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to @user }
      format.json { head :no_content }
    end
  end

  private

    # Define +@user+ based on route +:user_id+
    def get_user
      @user = User.find_by(username: params[:user_id])
    end

    # Define +@membership+ based on route +:id+
    def get_membership
      @membership = Membership.find(params[:id])
    end

    # Strong params for +Membership+
    def membership_params
      params.require(:membership).permit(:user_id, :year, info: [:override], privileges: [])
    end
end
