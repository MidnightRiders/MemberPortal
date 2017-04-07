# Decorator methods for +Match+ model.
class MatchDecorator < Draper::Decorator
  delegate_all

  # Returns <tt>a.button.secondary</tt> for +RevGuess+ for given match.
  # +size+ defaults to 'small'. If +o+ (for opponent) is true, the button includes match
  # opponent information.
  def rev_guess_button(size = 'small', o = false)
    h.link_to h.rev_guess_path(model), class: "button #{size}" do
      opp = o ? opponent : ''
      h.icon('question fa-fw') + ' RevGuess ' + opp + (": #{h.rev_guess_for(model)}" if h.rev_guess_for(model))
    end
  end

  # Returns <tt>a.button.secondary</tt> for +MotM+ for given match.
  # +size+ defaults to 'tiny'. If +o+ (for opponent) is true, the button includes match
  # opponent information.
  def mot_m_button(size = 'small', o = false)
    opp = o ? opponent : ''
    h.link_to h.mot_m_path(model), class: "button #{size}", title: "Man of the Match #{opp}" do
      h.icon('list-ol fa-fw') + ' MotM ' + opp + (h.icon('check fa-fw') if h.mot_m_for(model))
    end
  end

  # Returns buttons for editing/deleting a match
  def admin_controls
    h.capture do
      h.concat h.link_to(h.icon('pencil fa-fw'), h.edit_match_path(model), title: 'Edit') if h.can? :edit, model
      h.concat h.link_to(h.icon('trash-o fa-fw'), model, method: :delete, data: { confirm: 'Are you sure?' }, title: 'Destroy') if h.can? :destroy, model
    end
  end

  private

  # Determines opponent and returns 'v' or '@' depending on home/away status.
  def opponent
    (model.home_team == h.revs ? 'v ' : '@ ') + (model.teams - [h.revs])[0].abbrv
  end
end
