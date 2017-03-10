class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :first_name, :last_name, :member_since

  attribute :address, if: :is_admin?
  attribute :city, if: :is_admin?
  attribute :state, if: :is_admin?
  attribute :postal_code, if: :is_admin?
  attribute :phone, if: :is_admin?
  attribute :email, if: :is_admin?
  attribute :created_at, if: :is_admin?
  attribute :updated_at, if: :is_admin?
  delegate :current_user, to: :scope

  def is_admin?
    current_user.can? :manage, object
  end
end
