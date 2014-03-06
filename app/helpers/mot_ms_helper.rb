module MotMsHelper

  def mot_m_for(match)
    vote = match.mot_ms.find_by(user_id: current_user.id)
    if vote
      [match, vote]
    else
      nil
    end
  end

  def mot_m_path_for(match)
    mot_m_for(match) || new_match_mot_m_path(match)
  end
end
