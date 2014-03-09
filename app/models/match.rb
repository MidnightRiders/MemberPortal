class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Club'
  belongs_to :away_team, class_name: 'Club'

  default_scope includes(:home_team,:away_team).order('kickoff ASC')
  scope :completed, -> {
    includes(:home_team, :away_team).where('home_goals != ? AND away_goals != ?', nil, nil).order('kickoff ASC')
  }
  scope :upcoming, -> {
    includes(:home_team, :away_team).where('kickoff <= ?', Time.now).order('kickoff ASC')
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

  def next
    Match.where('kickoff > ?', kickoff).order('kickoff ASC').first
  end
  def previous
    Match.where('kickoff < ?', kickoff).order('kickoff DESC').first
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
    ms = where('kickoff >= ?', Time.now).order('kickoff DESC')
    if n==1
      ms.first
    else
      ms.first(n)
    end
  end

end
