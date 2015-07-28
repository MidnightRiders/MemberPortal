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
        new_user = @relative_user.persisted?
        @relative_user.save(validate: false) unless new_user
        @relative = @relative_user.memberships.new(type: 'Relative', year: @family.year, family_id: @family.id, info: { pending_approval: true })
        @relative.save(validate: false)
        if new_user
          MembershipMailer.invite_existing_user_to_family(@relative_user, @family, @relative).deliver
        else
          MembershipMailer.invite_new_user_to_family(@relative_user, @family, @relative).deliver
        end
        redirect_to user_membership_path(@user, @family), flash: { success: "#{@relative_user.email} has been invited to join your family membership." }
      else
        @relative_user.errors.add(:email, 'does not appear to be valid')
        render action: 'new'
      end
    end
  end

  # POST /users/:username/memberships/relatives/1/accept_invitation
  def accept_invitation
    if @relative.pending_approval
      if @relative.update_attribute(:info, @relative.info.except(:pending_approval))
        redirect_to user_home_path, flash: { success: "You are now a member of #{@relative.family.user.first_name}’s #{@relative.family.year} Family Membership." }
      else
        redirect_to user_home_path, flash: { error: @relative.errors.to_sentence }
      end
    else
      redirect_to user_home_path, flash: { error: 'This membership is not eligible to accept a family membership.' }
    end
  end

  # DELETE /users/memberships/relatives/1
  # DELETE /users/memberships/relatives/1.json
  def destroy
    @relative_user = @relative.user
    pending_approval = @relative.pending_approval
    @relative.destroy
    name = @relative_user.valid? ? "#{@relative_user.first_name} #{@relative_user.last_name}" : @relative_user.email
    @relative_user.destroy if pending_approval && @relative_user.memberships.reload.empty?
    respond_to do |format|
      format.html { redirect_to user_membership_path(@user, @family), flash: { success: "#{name} was successfully removed from your membership." } }
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
