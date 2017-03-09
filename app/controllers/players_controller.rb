# Controller for +Player+ model.
class PlayersController < ApplicationController
  load_and_authorize_resource

  # GET /players
  # GET /players.json
  def index
    @players = Player.all
  end

  # GET /players/new
  def new
    @player = Player.new(club_id: revs.id)
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render action: 'show', status: :created, location: @player }
      else
        format.html { render action: 'new' }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json {
          @players = Player.all
          render json: { selector: 'main', html: render_to_string(action: 'index', layout: false, formats: [:html]) }
        }
      else
        format.html { render action: 'edit' }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def player_params
    params.require(:player).permit(:first_name, :last_name, :club_id, :position, :number, :active)
  end
end
