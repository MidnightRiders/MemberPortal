# Controller for Devise Registrations.
class RegistrationsController < Devise::RegistrationsController

  def new
    build_resource({ email: params[:email] })
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
    respond_with self.resource
  end

  # Supercedes Devise +update+ method to allow editing of other users if admin.
  # def update
  #   account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
  #
  #   # required for settings form to submit when password is left blank
  #   if account_update_params[:password].blank?
  #     account_update_params.delete('password')
  #     account_update_params.delete('password_confirmation')
  #   end
  #
  #   @user = User.find(params[:id])
  #   is_current_user = @user == current_user
  #   if @user.update_attributes(account_update_params)
  #     set_flash_message :notice, :updated
  #     # Sign in the user bypassing validation in case his password changed
  #     sign_in(@user, :bypass => true) if is_current_user
  #     redirect_to after_update_path_for(@user)
  #   else
  #     render "edit"
  #   end
  # end

  protected

    def after_sign_up_path_for(resource)
      if Membership.with_invited_email(resource.email).present?
        user_home_path
      else
        new_user_membership_path(resource)
      end
    end
end
