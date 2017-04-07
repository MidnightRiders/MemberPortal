# Controller for +RevGuess+ model.
class RevGuessesController < ApplicationController
  before_action :check_eligible, only: %i(create)
  before_action :set_match
  before_action :set_rev_guess
  skip_before_action :verify_authenticity_token, only: %i(create)
  # TODO: Extract JSON endpoints to api/v1

  def show
    render json: @rev_guess, serializer: RevGuessSerializer, scope: view_context
  end

  # POST /rev_guesses
  # POST /rev_guesses.json
  def create
    @rev_guess.assign_attributes rev_guess_params

    respond_to do |format|
      if @rev_guess.save
        format.html { redirect_to matches_url(date: @match.kickoff.to_date), notice: 'RevGuess was successfully made.' }
        format.json { render json: @rev_guess, serializer: RevGuessSerializer, scope: view_context, status: :created, location: @rev_guess }
      else
        format.html {
          redirect_to matches_url(date: @match.kickoff.to_date),
            notice: 'There was an issue submitting your RevGuess: ' + @rev_guess.errors.messages.to_sentence
        }
        format.json { render json: @rev_guess.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def check_eligible
    authorize! :manage, @rev_guess

    return if @match.teams.map(&:abbrv).include? 'NE'
    redirect_to matches_path(date: @match.kickoff.to_date), flash: { notice: 'Cannot submit RevGuess for that match.' }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.with_clubs.find(params[:match_id])
  end

  def set_rev_guess
    @rev_guess = @match.rev_guesses.find_or_initialize_by(user_id: current_user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rev_guess_params
    params.require(:rev_guess).permit(:home_goals, :away_goals, :comment)
  end
end
