# Decorator methods for +Match+ model.
class MatchDecorator < Draper::Decorator
  delegate_all

  # Returns <tt>a.button.secondary</tt> for +RevGuess+ for given match.
  # +size+ defaults to 'small'. If +o+ (for opponent) is true, the button includes match
  # opponent information.
  def rev_guess_button(size='small', o = false)
    h.link_to h.rev_guess_path_for(model), class: "button secondary #{size}" do
      opp = o ? opponent : ''
      h.icon('question fa-fw') + ' RevGuess ' + opp + (": #{h.rev_guess_for(model)}" if h.rev_guess_for(model))
    end
  end

  # Returns <tt>a.button.secondary</tt> for +MotM+ for given match.
  # +size+ defaults to 'tiny'. If +o+ (for opponent) is true, the button includes match
  # opponent information.
  def mot_m_button(size='small', o = false)
    opp = o ? opponent : ''
    h.link_to h.mot_m_path_for(model), class: "button secondary #{size}", title: "Man of the Match #{opp}" do
      h.icon('list-ol fa-fw') + ' MotM ' + opp + (h.icon('check fa-fw') if h.mot_m_for(model))
    end
  end

  # Returns formatted set of links for +PickEm+.
  def pick_em_buttons(*args)
    h.content_tag :div, class: "pick-em-buttons secondary-border border-all #{model.home_team.abbrv.downcase} #{'closed' unless model.kickoff.future?}", title: model.kickoff.future? ? 'Pick ’Em' : 'Voting Closed' do
      h.concat h.content_tag :div, pick_em_button(:home, *args), class: 'home'
      h.concat h.content_tag :div, pick_em_button(:draw, *args), class: 'draw'
      h.concat h.content_tag :div, pick_em_button(:away, *args), class: 'away'
    end
  end

  # Returns individual +PickEm+ links.
  # === options:
  #   +:user+ defaults to current_user. Not sure when it wouldn't be that.
  #  There used to be more options.
  def pick_em_button(pick, *args)
    opts = args.extract_options!
    user = opts[:user] || h.current_user
    team = model.send("#{pick}_team") if pick.in? [:home, :away]
    html_classes = ['choice', pick == :draw ? ['secondary'] : ['primary-bg', team.abbrv.downcase]].flatten
    user_pick = user.pick_for(model)
    html_classes << user_pick.try(:correct?) ? 'correct' : 'actual' if model.result == pick
    html_classes << (user.pick_for(model).try(:correct?) ? 'correct' : 'actual') if model.complete? && model.result == pick
    if user.pick_result(model) == PickEm::RESULTS[pick]
      html_classes << 'picked'
      html_classes << 'wrong' if user_pick.try(:incorrect?)
    end

    content = if team
      team.crest.blank? ? team.abbrv : h.image_tag(team.crest.url(:thumb), title: team.name)
    else
      'D'
    end

    if model.in_past?
       h.content_tag(:div, content, class: html_classes.join(' '))
    else
      h.link_to(
        content,
        h.vote_match_pick_ems_path(model),
        data: {
          remote: true,
          method: :post,
          params: {
            pick_em: {
              user_id: user.id,
              match_id: model.id,
              result: PickEm::RESULTS[pick]
            }
          }.to_param
        },
        class: html_classes
      )
    end
  end

  # Returns formatted info that goes below the PickEm buttons - team records and optional
  # admin controls.
  def pick_em_sub
    h.content_tag :div, class: 'row collapse pick-em-sub' do
      h.concat h.content_tag :div, model.home_team.decorate.formatted_record(true), class: 'small-4 columns text-center'
      h.concat(h.content_tag :div, admin_controls, class: 'small-4 columns text-center') if h.can?(:manage, model)
      h.concat h.content_tag :div, model.away_team.decorate.formatted_record(true), class: 'small-4 columns right text-center'
    end
  end


  # Returns buttons for editing/deleting a match
  def admin_controls
    h.capture do
      h.concat h.link_to(h.icon('pencil fa-fw'), h.edit_match_path(model), title: 'Edit') if h.can? :edit, model
      h.concat h.link_to(h.icon('trash-o fa-fw'),  model, method: :delete, data: { confirm: 'Are you sure?' }, title: 'Destroy') if h.can? :destroy, model
    end
  end

  private

    # Determines opponent and returns 'v' or '@' depending on home/away status.
    def opponent
      (model.home_team == h.revs ? 'v ' : '@ ')+  (model.teams - [h.revs])[0].abbrv
    end
end
