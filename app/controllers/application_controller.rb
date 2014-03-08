class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_next_revs_match

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  private
    def set_next_revs_match
      @next_revs_match = Club.find_by(abbrv: 'NE').next_match
    end
end
