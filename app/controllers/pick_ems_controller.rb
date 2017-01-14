# Controller for +PickEm+ model.
class PickEmsController < ApplicationController
  load_and_authorize_resource
  before_action :set_match

  # GET /pick_ems
  # GET /pick_ems.json
  def index
    @pick_ems = PickEm.all
  end

  # POST /matches/:match_id/pickem/vote
  # Updates or creates +PickEm+ for match from given user.
  def vote
    p = params[:pick_em]
    @pick_em = PickEm.find_or_initialize_by(user_id: p[:user_id], match_id: p[:match_id])
    @pick_em.attributes = p
    response = if @pick_em.new_record? || @pick_em.changed?
      if @pick_em.save
        { status: :success, notice: 'Your vote was cast', pick_em: @pick_em, result: PickEm::RESULTS.key(@pick_em.result) }
      else
        { errors: @pick_em.errors, status: :unprocessable_entity }
      end
    else
      { status: :success, notice: 'No changes necessary' }
    end
    render json: response
  end

  # GET /pick_ems/1
  # GET /pick_ems/1.json
  # def show
  # end

  # GET /pick_ems/new
  # def new
  #   @pick_em = PickEm.new
  # end

  # GET /pick_ems/1/edit
  # def edit
  # end

  # POST /pick_ems
  # POST /pick_ems.json
  # def create
  #   @pick_em = PickEm.new(pick_em_params)
  #
  #   respond_to do |format|
  #     if @pick_em.save
  #       format.html { redirect_to @pick_em, notice: 'Pick em was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @pick_em }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @pick_em.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /pick_ems/1
  # PATCH/PUT /pick_ems/1.json
  # def update
  #   respond_to do |format|
  #     if @pick_em.update(pick_em_params)
  #       format.html { redirect_to @pick_em, notice: 'Pick em was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @pick_em.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /pick_ems/1
  # DELETE /pick_ems/1.json
  def destroy
    @pick_em.destroy
    respond_to do |format|
      format.html { redirect_to pick_ems_url }
      format.json { head :no_content }
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
