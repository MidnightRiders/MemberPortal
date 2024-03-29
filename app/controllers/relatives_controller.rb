class RelativesController < ApplicationController
  load_and_authorize_resource except: %i[new create]
  before_action :get_user_family

  # GET /users/:username/memberships/:membership_id/relatives/new
  def new
    @relative = @family.relatives.new
    authorize! :create, @relative
    @relative_user = @relative.user = User.new
  end

  # POST /users/:username/memberships/:membership_id/relatives
  def create
    @relative_user = User.find_or_initialize_by(relative_params[:user_attributes])

    if @relative_user.current_member?
      redirect_to new_user_membership_relative_path(@family.user, @family), flash: { alert: 'There is already a user with a current membership for that email.' }
    else
      if Devise.email_regexp =~ @relative_user.email
        @relative = Relative.new(year: @family.year, family_id: @family.id, info: { pending_approval: true, invited_email: @relative_user.email })
        authorize! :create, @relative
        @relative.save(validate: false)
        if @relative_user.persisted?
          MembershipMailer.invite_existing_user_to_family(@relative_user, @family, @relative).deliver_now
        else
          MembershipMailer.invite_new_user_to_family(@relative_user, @family, @relative).deliver_now
        end
        redirect_to user_membership_path(@user, @family), flash: { success: "#{@relative_user.email} has been invited to join your family membership." }
      else
        @relative_user.errors.add(:email, 'does not appear to be valid')
        render action: 'new'
      end
    end
  end

  # DELETE /users/:username/memberships/:membership_id/relatives/1
  # DELETE /users/:username/memberships/:membership_id/relatives/1.json
  def destroy
    @relative_user = @relative.user
    name = @relative_user.present? ? "#{@relative_user.first_name} #{@relative_user.last_name}" : @relative.invited_email
    @relative.destroy
    unless current_user.in? [@user, @relative_user].reject(&:nil?)
      Rails.logger.info "current_user: #{current_user}\n@user: #{@user}\n@relative_user: #{@relative_user}"
      raise 'current_user is neither @user nor @relative'
    end
    respond_to do |format|
      format.html do
        if @relative_user.present? && current_user == @relative_user
          redirect_to user_home_path(@relative_user), flash: { success: "Your Relative membership with #{@user.first_name} #{@user.last_name} has been destroyed." }
        else
          redirect_to user_membership_path(@user, @family), flash: { success: "#{name} was successfully removed from your membership." }
        end
      end
      format.json { head :no_content }
    end
  end

  # POST /users/:username/memberships/:membership_id/relatives//accept_invitation
  def accept_invitation
    if @relative.pending_approval
      if (@relative_user = User.find_by(email: @relative.invited_email)).present? && @relative.update(user_id: @relative_user.id, info: @relative.info.with_indifferent_access.except(:pending_approval, :invited_email))
        MembershipNotifier.new(user: @relative_user, membership: @relative).notify_relative
        redirect_to user_home_path, flash: { success: "You are now a member of #{@relative.family.user.first_name}’s #{@relative.family.year} Family Membership." }
      else
        redirect_to user_home_path, flash: { alert: @relative.errors.full_messages.to_sentence }
      end
    else
      redirect_to user_home_path, flash: { alert: 'This membership is not eligible to accept a family membership.' }
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

  # Never trust parameters from the scary internet, only allow the allowlist through.
  def relative_params
    r = params.require(:relative).permit(user_attributes: [:email])
    r[:user_attributes][:email].downcase! if r[:user_attributes].try(:[], :email)
    r
  end
end
