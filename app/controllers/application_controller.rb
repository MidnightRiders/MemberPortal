# Root controller for Application.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_next_revs_match
  before_filter :configure_permitted_parameters, if: :devise_controller?

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}" if Rails.env.development?
    flash[:error] = exception.message
    redirect_to root_url
  end

  protected
    # Strong parameters for Devise.
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up){|u| u.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, memberships: [ :year, :type, :privileges ])}
      devise_parameter_sanitizer.for(:account_update){|u| u.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, :current_password, memberships: [ :year, :type, :privilegs ])}
    end

  private
    # Returns +Match+.
    def set_next_revs_match
      @next_revs_match = revs.try(:next_match)
    end

    # Returns +Club+ and caches associated +Matches+.
    def revs
      @revs ||= Club.includes(:home_matches,:away_matches).find_by(abbrv: 'NE')
    end
end
