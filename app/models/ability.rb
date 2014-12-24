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
    if user
      can :home, [User]
      if user.current_member?
        if user.privilege? 'admin'
          can :manage, :all
          can :grant_privileges, Membership
        elsif user.privilege? 'executive_board'
          can :manage, [ User, Membership, Club, Match, Player, RevGuess ]
          cannot :destroy, [ Club, Player ]
          can :create, [ User, Membership ]
          can :read, :all
          can :index, MotM
        else
          can :show, [User, Club, Match]
          can :index, Match
          can :manage, [ user, user.memberships, user.mot_ms, user.rev_guesses, user.pick_ems ]
          can :create, [ Membership, MotM, RevGuess ], user_id: user.id
          can :vote, PickEm, user_id: user.id
          if user.current_membership.is_a? Family
            can :create, Relative, membership_id: user.current_membership.id
            can :manage, [ user.current_membership.relatives, user.current_membership.relatives.map(&:user) ]
          end
          cannot :index, [ Club, Membership, Player, User, MotM, Relative, Family ]
          cannot :grant_privileges, Membership
        end
      end
    else
      cannot :index, :all
      cannot :manage, :all
      can :create, :Registration
    end
  end
end
