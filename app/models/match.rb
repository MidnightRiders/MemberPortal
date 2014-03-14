class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Club'
  belongs_to :away_team, class_name: 'Club'

  default_scope {
    includes(:home_team,:away_team)
  }
  scope :completed, -> {
    where('home_goals != ? AND away_goals != ?', nil, nil)
  }
  scope :upcoming, -> {
    where('kickoff > ?', Time.now)
  }

  has_many :mot_ms
  has_many :rev_guesses
  has_many :pick_ems

  validates :home_team, :away_team, :kickoff, :location, presence: true
  validates :uid, uniqueness: { case_sensitive: true, allow_blank: true }

  def score
    if complete?
      "#{home_goals || 0} – #{away_goals || 0}"
    else
      '—'
    end
  end

  def complete?
    !home_goals.blank? && !away_goals.blank?
  end

  def result
    if home_goals.nil? || away_goals.nil?
      nil
    else
      if home_goals > away_goals
        :home
      elsif away_goals > home_goals
        :away
      else
        :draw
      end
    end
  end

  def voteable?
    kickoff && Time.now > kickoff + 45.minutes
  end
  def in_future?
    kickoff && kickoff > Time.now
  end
  def in_past?
    !in_future?
  end

  def teams
    [ home_team, away_team ]
  end

  def next
    Match.where('kickoff >= ?', kickoff).order('kickoff ASC, id ASC').select{|x| [x.home_team_id,x.away_team_id] != [home_team_id,away_team_id] && (x.id < id || x.kickoff > kickoff) }.first
  end
  def previous
    Match.where('kickoff <= ?', kickoff).order('kickoff DESC, id DESC').select{|x| [x.home_team_id,x.away_team_id] != [home_team_id,away_team_id] && (x.id > id || x.kickoff < kickoff) }.first
  end
  def self.previous(n=1)
    ms = where('kickoff < ?', Time.now).order('kickoff DESC')
    if n==1
      ms.first
    else
      ms.first(n)
    end
  end
  def self.next(n=1)
    ms = upcoming.order('kickoff DESC')
    if n==1
      ms.first
    else
      ms.first(n)
    end
  end

end
