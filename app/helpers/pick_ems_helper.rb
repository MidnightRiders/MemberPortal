module PickEmsHelper
  def pick_em_link(match, vote, *args)
    opts = args.extract_options!
    user = opts[:user] || current_user
    long = opts[:long]
    team = if vote == :home
      match.home_team
    elsif vote == :away
      match.away_team
    end
    html_classes = ['choice']
    html_classes += if vote == :draw
      ['secondary']
    else
      ['primary-bg', team.abbrv.downcase]
    end
    if match.complete? && match.result == vote
      if user.pick_for(match).try(:correct?)
        html_classes << 'correct'
      elsif match.result == vote
        html_classes << 'actual'
      end
    end
    if user.pick_result(match) == PickEm::RESULTS[vote]
      html_classes << 'picked'
      html_classes << 'wrong' if user.pick_for(match).try(:wrong?)
    end

    content = if long
      team ? team.name : 'Draw'
    else
      team ? team.abbrv : 'D'
    end
    if match.kickoff.past?
      content_tag(:div, content, class: html_classes.join(' '))
    else
      link_to(
        content,
        vote_match_pick_ems_path(match),
        remote: true,
        method: :post,
        data: {
          params: {
            pick_em: {
              user_id: user.id,
              match_id: match.id,
              result: PickEm::RESULTS[vote]
            }
          }.to_param
        },
        class: html_classes.join(' ')
      )
    end
  end
end
