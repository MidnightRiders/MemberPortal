module MotMsHelper
  def mot_m_for(match)
    match.mot_ms.find_by(user_id: current_user.id)
  end

  def mot_m_path_for(match)
    if mot_m_for(match)
      edit_match_mot_m_path(match,mot_m_for(match))
    else
      new_match_mot_m_path(match)
    end
  end
end
