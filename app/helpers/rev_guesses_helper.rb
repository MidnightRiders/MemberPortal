# Helper for +RevGuesse+ model.
module RevGuessesHelper

  # Returns +RevGuess+ for given +match+ for the current user.
  def rev_guess_for(match)
    match.rev_guesses.find_by(user_id: current_user.id)
  end

  # Returns +RevGuess+ path for given +match+ for the current user:
  # new_match_rev_guess_path if one doesn't exist, edit_match_rev_guess_path
  # if it does.
  def rev_guess_path_for(match)
    if rev_guess_for(match)
      edit_match_rev_guess_path(match,match.rev_guesses.find_by(user_id: current_user.id))
    else
      new_match_rev_guess_path(match)
    end
  end
end
