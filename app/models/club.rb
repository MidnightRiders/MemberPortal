class Club < ActiveRecord::Base

  # Only two conferences right now. No need for database records, so
  # they're stored in this constant.
  CONFERENCES = %w(east west).freeze

  has_attached_file :crest,
    storage: :s3,
    path: '/:class/:attachment/:id/:style_:filename',
    default_style: :standard,
    styles: {
      thumb: '100x100>',
      standard: '250x250>'
    }

  validates :name, :abbrv, :primary_color, :secondary_color, :accent_color, presence: true
  validates :name, :abbrv, uniqueness: true
  validates :conference, inclusion: CONFERENCES, allow_blank: false
  validates :primary_color, :secondary_color, :accent_color, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 'ffffff'.to_i(16) }
  validates_attachment :crest, content_type: { content_type: %w(image/jpg image/gif image/png) }

  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team_id'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team_id'

  has_many :players

  # Hacky function that's not really production-ready (too database-heavy) but will get standings of clubs for
  # use in console etc at least.
  def self.standings(options = {})
    opts = {
      float: 2,
      format: :raw
    }.deep_merge(options)
    clubs = Club.includes(:home_matches, :away_matches).where.not(matches: { id: nil }).map { |c|
      c.attributes.symbolize_keys.merge(
        wins: c.wins.size,
        draws: c.draws.size,
        losses: c.losses.size,
        points: c.wins.size * 3 + c.draws.size,
        ppg: ((c.wins.size * 3 + c.draws.size).to_f / c.matches.completed.size).round(opts[:float])
      )
    }.sort_by { |c| [c[:points], c[:ppg]] }.reverse
    case opts[:format]
    when :text
      clubs.map { |c| "#{c[:abbrv]} | #{c[:points]} | #{c[:ppg]} | #{c[:wins]} | #{c[:draws]} | #{c[:losses]}" }.join("\n")
    else
      clubs
    end
  end

  # Returns *Array* of +Matches+ involving the club.
  def matches
    Match.with_clubs.where('home_team_id = :id OR away_team_id = :id', id: id).order(kickoff: :asc)
  end

  # Returns +Match+ or *Array* of +Matches+, depending on +n+, before +time+ (defaults to now).
  def previous_matches(n = 1, time = Time.current)
    ms = matches.where('kickoff < :time', time: time).reorder(kickoff: :desc)
    n == 1 ? ms.first : ms.first(n)
  end

  # Returns +Match+ or *Array* of +Matches+, depending on +n+, after +time+ (defaults to now).
  def next_matches(n = 1, time = Time.current)
    ms = matches.where('kickoff >= :time', time: time)
    n == 1 ? ms.first : ms.first(n)
  end

  # Alias for <tt>next_matches(1)</tt>
  def next_match
    next_matches(1)
  end

  # Alias for <tt>previous_matches(1)</tt>
  def last_match
    previous_matches(1)
  end

  # Returns *Array* of +Matches+ that the club has won.
  def wins
    matches.select { |x| x.winner == self }
  end

  # Returns *Array* of +Matches+ that the club has lost.
  def losses
    matches.select { |x| x.loser == self }
  end

  # Returns *Array* of +Matches+ that the club has drawn.
  def draws
    matches.select { |x| x.result == :draw }
  end

  # Returns *String* in format of "W-L-D".
  def record
    "#{wins.size}-#{losses.size}-#{draws.size}"
  end

  # Sets color methods which return *String*s.
  %w(primary secondary accent).each do |x|
    define_method("#{x}_color=") do |val|
      self["#{x}_color"] = val.to_s.to_i(16)
    end

    define_method("#{x}_color") do
      self["#{x}_color"].to_s(16).rjust(6, '0') unless self["#{x}_color"].nil?
    end
  end

  # Returns *String*. Color method that falls back to +accent_color+ if +secondary_color+ is white.
  def dark_compliment
    secondary_color == 'ffffff' ? accent_color : secondary_color
  end

  def self.from_string(name)
    return find_by(abbrv: 'NYC') if name =~ /New ?York ?City/i

    FuzzyMatch.new(all, read: :name).find(name)
  end
end
