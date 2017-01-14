# Helper for +MotM+ model.
module MotMsHelper

  # Returns +MotM+ for +match+ for current user.
  def mot_m_for(match)
    match.mot_ms.find_by(user_id: current_user.id)
  end

  # Returns path for +MotM+ form: new if it doesn't already exist,
  # edit if it does.
  def mot_m_path_for(match)
    if mot_m_for(match)
      edit_match_mot_m_path(match, mot_m_for(match))
    else
      new_match_mot_m_path(match)
    end
  end
end
