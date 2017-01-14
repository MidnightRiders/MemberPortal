# Controller for +RevGuess+ model.
class RevGuessesController < ApplicationController
  load_and_authorize_resource
  before_action :set_match

  # GET /rev_guesses/new
  def new
    @rev_guess = RevGuess.new
  end

  # GET /rev_guesses/1/edit
  def edit; end

  # POST /rev_guesses
  # POST /rev_guesses.json
  def create
    @rev_guess = RevGuess.new(rev_guess_params)

    respond_to do |format|
      if @rev_guess.save
        format.html do redirect_to matches_url(date: @match.kickoff.to_date), notice: 'RevGuess was successfully created.' end
        format.json { render action: 'show', status: :created, location: @rev_guess }
      else
        format.html do render action: 'new' end
        format.json { render json: @rev_guess.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rev_guesses/1
  # PATCH/PUT /rev_guesses/1.json
  def update
    respond_to do |format|
      if @rev_guess.update(rev_guess_params)
        format.html do redirect_to matches_url(date: @match.kickoff.to_date), notice: 'RevGuess was successfully updated.' end
        format.json { head :no_content }
      else
        format.html do render action: 'edit' end
        format.json { render json: @rev_guess.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rev_guesses/1
  # DELETE /rev_guesses/1.json
  def destroy
    @rev_guess.destroy
    respond_to do |format|
      format.html do redirect_to rev_guesses_url end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.with_clubs.find(params[:match_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rev_guess_params
    params.require(:rev_guess).permit(:match_id, :user_id, :home_goals, :away_goals, :comment)
  end
end
