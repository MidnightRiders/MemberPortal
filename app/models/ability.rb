# Defines user abilities and permissions.
class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user
      can :home, [User]
      can :manage, user
      if user.current_member?
        can :show, :download
        can :vote, Poll do |poll|
          poll.active?
        end
        cannot :create, :Registration
        if user.privilege? 'admin'
          can :manage, :all
          cannot :edit, Poll do |poll|
            poll.start_time > Time.current
          end
          # Implicit
          # can :refund, Membership, year: (Date.current.year..Date.current.year + 1)
          # can :grant_privileges, Membership
        elsif user.privilege? 'executive_board'
          can :manage, [User, Membership, Club, Match, Player, RevGuess]
          cannot :destroy, [Club, Player]
          can :create, [User, Membership]
          can :read, :all
          can :index, MotM
          can :transactions, :static_page
          can %i[index show], Poll
        else
          can :show, [User, Club, Match]
          can :index, Match
          can :manage, Membership do |membership|
            membership == user.current_membership
          end
          can :manage, [MotM, RevGuess, PickEm], user: user
          can :create, [MotM, RevGuess], user: user
          can :vote, PickEm, user: user
          cannot :manage, Relative
          if user.current_membership.is_a? Family
            can :manage, Relative do |relative|
              relative.family_id == user.current_membership.id
            end
            can :manage, User do |u|
              user.current_membership.relatives.map(&:user).include? u
            end
          end
          cannot :index, [Club, Membership, Player, User, MotM, Relative, Family]
          cannot :refund, Membership
          cannot :grant_privileges, Membership
        end
        can :standings, :static_page
        can :nominate, :static_page
        can :show, user.current_membership
        cannot :cancel_subscription, Membership
        can :cancel_subscription, user.current_membership if user.current_membership.subscription?
      elsif user.invited_to_family?
        can :manage, user.family_invitation
        can :create, Membership, user: user
      else
        can :create, Membership, user: user
      end
    else
      cannot :index, :all
      cannot :manage, :all
      can :create, :Registration
    end
  end
end
