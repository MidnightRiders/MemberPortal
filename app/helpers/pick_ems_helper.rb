module PickEmsHelper
  def pick_em_link(match, vote)
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
    html_classes << 'picked' if current_user.pick_for(match) == PickEm::RESULTS[vote]
    link_to(
      team ? team.abbrv : 'D',
      vote_match_pick_ems_path(match),
      remote: true,
      method: :post,
      data: {
        params: {
          pick_em: {
            user_id: current_user.id,
            match_id: match.id,
            result: PickEm::RESULTS[vote]
          }
        }.to_param
      },
      class: html_classes.join(' ')
    )
  end
end
