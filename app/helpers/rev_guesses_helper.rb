module RevGuessesHelper

  def rev_guess_for(match)
    vote = match.rev_guesses.find_by(user_id: current_user.id)
    if vote
      [match, vote]
    else
      nil
    end
  end

  def rev_guess_path_for(match)
    if rev_guess_for(match)
      edit_match_rev_guess_path(match,match.rev_guesses.find_by(user_id: current_user.id))
    else
      new_match_rev_guess_path(match)
    end
  end
end
