# Helper for +MotM+ model.
module MotMsHelper

  # Returns +MotM+ for +match+ for current user.
  def mot_m_for(match)
    match.mot_ms.find_by(user_id: current_user.id)
  end
end
