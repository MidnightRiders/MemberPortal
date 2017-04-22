# Controller for +PickEm+ model.
class PickEmsController < ApplicationController
  load_and_authorize_resource
  before_action :set_match

  # POST /matches/:match_id/pickem/vote
  # Updates or creates +PickEm+ for match from given user.
  def create
    @pick_em = @match.pick_ems.find_or_initialize_by(user_id: current_user.id)
    head :not_modified and return if @pick_em.result == pick_em_params[:result]&.to_i
    if @pick_em.update(result: pick_em_params[:result])
      render json: { result: @pick_em.result_key }, status: :accepted
    else
      render json: { errors: @pick_em.errors }, status: :unprocessable_entity
    end
  end

  private

  # Sets +@match+ based on route's +:match_id+.
  def set_match
    @match = Match.with_clubs.find(params[:match_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pick_em_params
    params.require(:pick_em).permit(:match_id, :user_id, :result)
  end
end
