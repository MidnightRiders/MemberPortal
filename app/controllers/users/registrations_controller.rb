class RegistrationsController < Devise::RegistrationsController
  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete('password')
      account_update_params.delete('password_confirmation')
    end

    @user = User.find(params[:id])
    is_current_user = @user == current_user
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in(@user, :bypass => true) if is_current_user
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end
end