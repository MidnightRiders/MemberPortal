class MatchDecorator < Draper::Decorator
  delegate_all

  def rev_guess_button(size='tiny', opponent = false)
    h.link_to h.rev_guess_path_for(model), class: "button secondary #{size}" do
      opp = opponent ? (model.home_team == revs ? ' v ' : ' @ ')+  (model.teams - [revs])[0].abbrv : ''
      h.icon('question fa-fw') + ' RevGuess' + opp + (": #{h.rev_guess_for(model)[1]}" if h.rev_guess_for(model))
    end
  end

  def mot_m_button(size='tiny', opponent = false)
    h.link_to h.mot_m_path_for(model), class: "button secondary #{size}" do
      opp = opponent ? (model.home_team == revs ? ' v ' : ' @ ') +  (model.teams - [revs])[0].abbrv : ''
      h.icon('list-ol fa-fw') + ' MotM' + opp + (h.icon('check fa-fw') if h.mot_m_for(model))
    end
  end

  def pick_em_buttons(*args)
    h.content_tag :div, class: "pick-em-buttons secondary-border border-all #{model.home_team.abbrv.downcase} #{'closed' unless model.kickoff.future?}", title: model.kickoff.future? ? 'Pick ’Em' : 'Voting Closed' do
      h.concat h.content_tag :div, pick_em_button(:home, *args), class: 'home'
      h.concat h.content_tag :div, pick_em_button(:draw, *args), class: 'draw'
      h.concat h.content_tag :div, pick_em_button(:away, *args), class: 'away'
    end
  end

  def pick_em_button(pick, *args)
    opts = args.extract_options!
    user = opts[:user] || h.current_user
    team = model.send("#{pick}_team") if pick.in? [:home, :away]
    html_classes = ['choice', pick == :draw ? ['secondary'] : ['primary-bg', team.abbrv.downcase]].flatten
    html_classes << (user.pick_for(model).try(:correct?) ? 'correct' : 'actual') if model.complete? && model.result == pick
    if user.pick_result(model) == PickEm::RESULTS[pick]
      html_classes << 'picked'
      html_classes << 'wrong' if user.pick_for(model).try(:wrong?)
    end

    content = if team
      team.crest.blank? ? team.abbrv : h.image_tag('http://midnightriders.com' + team.crest.url(:thumb), title: team.name)
    else
      'D'
    end

    if model.in_past?
       h.content_tag(:div, content, class: html_classes.join(' '))
    else
      h.link_to(
        content,
        h.vote_match_pick_ems_path(model),
        remote: true,
        method: :post,
        data: {
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

  def pick_em_sub
    h.content_tag :div, class: 'row collapse pick-em-sub' do
      h.concat h.content_tag :div, model.home_team.decorate.formatted_record(true), class: 'small-4 columns text-center'
      h.concat(h.content_tag :div, admin_controls, class: 'small-4 columns text-center') if h.can?(:manage, model)
      h.concat h.content_tag :div, model.away_team.decorate.formatted_record(true), class: 'small-4 columns right text-center'
    end
  end


  def admin_controls
    h.capture do
      h.concat h.link_to(h.icon('pencil fa-fw'), h.edit_match_path(model), title: 'Edit') if h.can? :edit, model
      h.concat h.link_to(h.icon('trash-o fa-fw'),  model, method: :delete, data: { :confirm => 'Are you sure?' }, title: 'Destroy') if h.can? :destroy, model
    end
  end

  private
    def revs
      Club.find_by(abbrv: 'NE')
    end

    def opponent
      (model.home_team == revs ? 'v ' : '@ ')+  (model.teams - [revs])[0].abbrv
    end
end
