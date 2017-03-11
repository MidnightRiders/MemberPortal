class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :first_name, :last_name, :member_since

  attribute :address, if: :current_user_admin?
  attribute :city, if: :current_user_admin?
  attribute :state, if: :current_user_admin?
  attribute :postal_code, if: :current_user_admin?
  attribute :phone, if: :current_user_admin?
  attribute :email, if: :current_user_admin?
  attribute :created_at, if: :current_user_admin?
  attribute :updated_at, if: :current_user_admin?

  def current_user_admin?
    scope&.current_user&.can?(:manage, object)
  end
end
