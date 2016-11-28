# Root controller for Application.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_next_revs_match
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

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

  def current_ability
    @current_ability ||= Spree::Ability.new(current_user)
  end

  protected
    # Strong parameters for Devise.
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) do |user_params|
        user_params.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, memberships: [ :year, :type, :privileges ])
      end

      devise_parameter_sanitizer.permit(:account_update) do |user_params|
        user_params.permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, :password, :password_confirmation, :current_password, memberships: [ :year, :type, :privileges ])
      end
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

    def slack_notify_membership(membership, user, family=nil)
      relevant_memberships = Membership.where(year: membership.year, refunded: [nil, false]).where.not(user_id: nil)
      count = relevant_memberships.size
      breakdown = relevant_memberships.group(:year, :type).count
      breakdown = %w(Individual Family Relative).map { |type| "#{type}: #{breakdown[[membership.year, type]] || 0}" }.join(' | ')
      SlackBot.post_message("New #{membership.type} Membership!\n*#{membership.year} Total: #{count}* | #{breakdown}", '#general')
      if family.present?
        SlackBot.post_message("#{user.first_name} #{user.last_name} (@#{user.username}) has accepted *#{family.user.first_name} #{family.user.last_name}’s Family Membership invitation*:\n#{user_url(user)}.\nThere are now *#{count} registered #{membership.year} Memberships.*\n#{breakdown}", 'membership')
      else
        SlackBot.post_message("New #{membership.type} Membership for #{user.first_name} #{user.last_name} (<#{user_url(user)}|@#{user.username}>):\n*#{membership.year} Total: #{count}* | #{breakdown}", 'membership')
      end
    end
end
