class Api::V1::SessionSerializer < ActiveModel::Serializer
  attributes :auth_token, :expires_at
  belongs_to :user
end
