class Api::MatchesController < ApiController

  def next_revs_match
    render json: { match: revs&.next_match.as_json }
  end

  def show
    authorize! :read, Match

    @match = Match.find(params[:id])
    render json: { match: @match.as_json }
  end

  # TODO: match filtering
  def index
    authorize! :read, Match

    @matches = Match.all
    render json: { matches: @matches.as_json }
  end
end
