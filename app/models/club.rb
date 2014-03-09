class Club < ActiveRecord::Base
  CONFERENCES = %w(east west)
  validates :name, :abbrv, :primary_color, :secondary_color, :accent_color, presence: true
  validates :name, :abbrv, uniqueness: true
  validates :conference, inclusion: CONFERENCES, allow_blank: false
  validates :primary_color, :secondary_color, :accent_color, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 'ffffff'.to_i(16) }

  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team_id'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team_id'

  has_many :players

  def name
    if abbrv=='NE'
      '&star; '.html_safe + super
    else
      super
    end
  end
  def plain_name
    name
  end

  def matches
    (home_matches + away_matches).sort_by(&:kickoff)
  end

  def previous_matches(n=1,time=Time.now)
    home_matches.where('kickoff <= ?',time) + away_matches.where('kickoff <= ?',time)
  end
  def next_matches(n=1,time=Time.now)
    home_matches.where('kickoff > ?',time) + away_matches.where('kickoff > ?',time)
  end

  def next_match(x = 1)
    ms = matches.sort_by(&:kickoff).reject{|x| x.kickoff < Time.now }
    if x == 1
      ms.first
    else
      ms.first(x)
    end
  end
  def last_match(x = 1)
    ms = matches.sort_by(&:kickoff).reject{|x| x.kickoff > Time.now }.last(x)
    if x == 1
      ms.last
    else
      ms.last(x)
    end
  end

  def dark_compliment
    secondary_color == 'ffffff' ? accent_color : secondary_color
  end

  %w(primary secondary accent).each do |x|
    define_method("#{x}_color=") do |val|
      write_attribute("#{x}_color", val.to_i(16))
    end
    define_method("#{x}_color") do
      read_attribute("#{x}_color").to_s(16).rjust(6,'0') unless read_attribute("#{x}_color").nil?
    end
  end
end
