class Api::UsersController < ApplicationController
  load_and_authorize_resource

  def current
    if current_user.nil?
      render json: { user: null }, status: :unauthorized
    else
      render json: { user: current_user.as_json.transform_keys { _1.camelize(:lower) } }
    end
  end

  def show; end

  def index; end
end
