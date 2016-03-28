# Defines user abilities and permissions.
class Ability
  include CanCan::Ability

  # Define abilities for the passed in user here. For example:
  #
  #   if user.admin?
  #     can :manage, :all
  #   else
  #     can :read, :all
  #   end
  #
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user
      can :home, [ User ]
      can :manage, user
      can [:index, :show], Product, available?: true
      can [:manage, :place], user.orders
      if user.current_member?
        can :show, :download
        cannot :create, :Registration
        if user.privilege? 'admin'
          can :manage, :all
          # Implicit
          # can :refund, Membership, year: (Date.current.year..Date.current.year + 1)
          # can :grant_privileges, Membership
        elsif user.privilege? 'executive_board'
          can :manage, [ User, Membership, Club, Match, Player, RevGuess ]
          cannot :destroy, [ Club, Player ]
          can :create, [ User, Membership ]
          can :read, :all
          can :index, MotM
          can :transactions, :static_page
        else
          can :show, [ User, Club, Match ]
          can :index, Match
          can :manage, [ user.current_membership, user.mot_ms, user.rev_guesses, user.pick_ems ]
          can :create, [ MotM, RevGuess ], user_id: user.id
          can :vote, PickEm, user_id: user.id
          cannot :manage, Relative
          if user.current_membership.is_a? Family
            can :invite_relative, Membership
            can :manage, Relative, family_id: user.current_membership.id
            can :manage, [ user.current_membership.relatives, user.current_membership.relatives.map(&:user) ]
          end
          cannot :index, [ Club, Membership, Player, User, MotM, Relative, Family ]
          cannot :refund, Membership
          cannot :grant_privileges, Membership
        end
        can :standings, :static_page
        can :show, user.current_membership
        cannot :cancel_subscription, Membership
        can :cancel_subscription, user.current_membership if user.current_membership.is_subscription?
      elsif user.has_family_invitation?
        can :manage, user.family_invitation
        can :create, Membership, user_id: user.id
      else
        can :create, Membership, user_id: user.id
      end
    else
      cannot :index, :all
      cannot :manage, :all
      can :create, :Registration
      can [:index, :show], Product
    end
  end
end
