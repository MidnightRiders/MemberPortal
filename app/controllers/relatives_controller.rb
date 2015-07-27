class RelativesController < ApplicationController
  load_and_authorize_resource
  before_action :get_user_family

  # GET /users/memberships/relatives/new
  def new
    @relative = @family.relatives.new
    @relative_user = @relative.user = User.new
  end

  # GET /users/memberships/relatives/1/edit
  def edit
    @relative_user = @relative.user
  end

  # POST /users/memberships/relatives
  def create
    @relative_user = User.find_or_initialize_by(relative_params[:user_attributes])

    if @relative_user.current_member?
      redirect_to new_user_membership_relative_path(@family.user, @family), flash: { error: 'There is already a user with a current membership for that email.' }
    else
      if Devise::email_regexp =~ @relative_user.email
        @relative_user.save(validate: false)
        @relative = @family.relatives.create(year: @family.year, user: @relative_user, info: { pending_approval: true })
        redirect_to @relative, notice: 'Relative was successfully created.'
      else
        @relative_user.errors.add(:email, 'does not appear to be valid')
        render action: 'new'
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
    def get_user_family
      @user = User.find_by(username: params[:user_id])
      @family = @user.memberships.find(params[:membership_id])

      redirect_to user_home_path, notice: 'Your account type does not permit relatives.' unless @family.is_a? Family
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relative_params
      params.require(:relative).permit(user_attributes: [ :email ])
    end
end
