class RelativesController < ApplicationController
  load_and_authorize_resource
  before_action :get_user_membership

  # GET /users/memberships/relatives
  # GET /users/memberships/relatives.json
  def index
    @relatives = @membership.relatives.includes(:user)
  end

  # GET /users/memberships/relatives/1
  # GET /users/memberships/relatives/1.json
  def show
  end

  # GET /users/memberships/relatives/new
  def new
    @relative = @membership.relatives.new
    @relative_user = @relative.user.new
  end

  # GET /users/memberships/relatives/1/edit
  def edit
    @relative_user = @relative.user
  end

  # POST /users/memberships/relatives
  # POST /users/memberships/relatives.json
  def create
    @relative = @membership.relatives.new(relative_params)
    @relative_user = @relative.user.new()

    respond_to do |format|
      if @relative_user.save && @relative.save
        format.html { redirect_to @relative, notice: 'Relative was successfully created.' }
        format.json { render action: 'show', status: :created, location: @relative }
      else
        format.html { render action: 'new' }
        format.json { render json: @relative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/memberships/relatives/1
  # PATCH/PUT /users/memberships/relatives/1.json
  def update
    respond_to do |format|
      if @relative.update(relative_params)
        format.html { redirect_to @relative, notice: 'Relative was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @relative.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/memberships/relatives/1
  # DELETE /users/memberships/relatives/1.json
  def destroy
    @relative.destroy
    respond_to do |format|
      format.html { redirect_to user_membership_relatives_url }
      format.json { head :no_content }
    end
  end

  private
    # Get +User+ and +Membership+ records for Relative. Then
    # redirect to home unless +Membership+ is family
    def get_user_membership
      @user = User.find_by(username: params[:user_id])
      @membership = @user.memberships.find(params[:membership_id])

      redirect_to users_home_path, notice: 'Your account type does not permit relatives.' unless @membership.is_a? Family
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relative_params
      params.require(:relative).permit()
    end
end
