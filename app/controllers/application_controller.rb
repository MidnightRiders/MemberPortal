# Root controller for Application.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_next_revs_match
  before_action :configure_permitted_parameters, if: :devise_controller?
  serialization_scope :view_context

  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= __send__(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}" if Rails.env.development?
    flash[:error] = exception.message
    redirect_to root_url
  end

  protected

  # Strong parameters for Devise.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, memberships: %i(year type privileges))
    end

    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, :current_password, memberships: %i(year type privileges))
    end
  end

  private

  # Returns +Match+.
  def set_next_revs_match
    @next_revs_match = revs.try(:next_match)
  end

  # Returns +Club+ and caches associated +Matches+.
  def revs
    @revs ||= Club.includes(:home_matches, :away_matches).find_by(abbrv: 'NE')
  end
end
