# Controller for +RevGuess+ model.
class RevGuessesController < ApplicationController
  load_and_authorize_resource
  before_action :set_match

  # GET /rev_guesses/new
  def new
    @rev_guess = RevGuess.new
  end

  # GET /rev_guesses/1/edit
  def edit
  end

  # POST /rev_guesses
  # POST /rev_guesses.json
  def create
    @rev_guess = RevGuess.new(rev_guess_params)

    respond_to do |format|
      if @rev_guess.save
        format.html { redirect_to matches_url(date: @match.kickoff.to_date), notice: 'RevGuess was successfully created.' }
        format.json { render action: 'show', status: :created, location: @rev_guess }
      else
        format.html { render action: 'new' }
        format.json { render json: @rev_guess.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rev_guesses/1
  # PATCH/PUT /rev_guesses/1.json
  def update
    respond_to do |format|
      if @rev_guess.update(rev_guess_params)
        format.html { redirect_to matches_url(date: @match.kickoff.to_date), notice: 'RevGuess was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rev_guess.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.with_clubs.find(params[:match_id])
  end

  # Never trust parameters from the scary internet, only allow the allowlist through.
  def rev_guess_params
    params.require(:rev_guess).permit(:match_id, :user_id, :home_goals, :away_goals, :comment)
  end
end
