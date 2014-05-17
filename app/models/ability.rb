class Ability
  include CanCan::Ability

  def initialize(user)
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
    if user
      can :home, [User]
      if user.current_member?
        if user.role? 'admin'
          can :manage, :all
        elsif user.role? 'executive_board'
          can :manage, [ User, Membership, Club, Match, Player, RevGuess ]
          cannot :destroy, [ Club, Player ]
          can :create, [ User, Membership ]
          can :read, :all
          can :index, MotM
        else
          can :show, [User, Club, Match]
          can :index, Match
          can :manage, [ MotM, RevGuess, PickEm ], user_id: user.id
          cannot :index, [ Club, Membership, Player, User, MotM ]
          can :manage, user
          can :manage, Membership, user_id: user.id
        end
      end
    else
      cannot :index, :all
      cannot :manage, :all
      can :create, :Registration
    end
  end
end
