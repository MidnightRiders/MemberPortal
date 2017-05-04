class MatchDetailSerializer < MatchSerializer
  attribute :mot_m_players do
    if object.teams.map(&:abbrv).include? 'NE'
      Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds)
        .select { |x| x.mot_m_total(match_id: object.id) && x.mot_m_total(match_id: object.id).positive? }
        .sort_by { |x| x.mot_m_total(match_id: object.id) }
        .reverse
    end
  end

  attribute :pick_ems do
    object.pick_ems.reduce({ home: 0, draw: 0, away: 0 }) { |obj, pick_em|
      obj[pick_em.result_key.to_sym] += 1
      obj
    }
  end
end
