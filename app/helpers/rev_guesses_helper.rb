# Helper for +RevGuesse+ model.
module RevGuessesHelper

  # Returns +RevGuess+ for given +match+ for the current user.
  def rev_guess_for(match)
    match.rev_guesses.find_by(user_id: current_user.id)
  end
end
