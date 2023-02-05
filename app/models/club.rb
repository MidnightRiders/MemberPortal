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
  validates :api_id, presence: true, uniqueness: true
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
    matches.where(kickoff: time..).take(n == 1 ? nil : n)
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
  %w[primary secondary accent].each do |x|
    define_method("#{x}_color=") do |val|
      self["#{x}_color"] = val.to_s.to_i(16)
    end

    define_method("#{x}_color") do
      self["#{x}_color"]&.to_s(16)&.rjust(6, '0')
    end
  end

  def color_on_primary
    secondary_contrast = contrast(primary_color, secondary_color)
    return secondary_color if secondary_contrast >= 7.0

    accent_contrast = contrast(primary_color, accent_color)
    return accent_color if accent_contrast >= 7.0

    pct = luminosity(primary_color) < 0.5 ? 0.1 : -0.1
    col = secondary_contrast > accent_contrast ? secondary_color : accent_color
    col = adjust_color(col, pct) while !%w[ffffff fff 000000 000].include?(col) && contrast(primary_color, col) < 7.0
    col
  end

  # Returns *String*. Color method that falls back to +accent_color+ if +secondary_color+ is white.
  def dark_compliment
    secondary_color == 'ffffff' ? accent_color : secondary_color
  end

  def self.from_string(name)
    return find_by(abbrv: 'NYC') if name =~ /New ?York ?City/i

    FuzzyMatch.new(all, read: :name).find(name)
  end

  private

  def contrast(one, two)
    l1 = luminosity(one)
    l2 = luminosity(two)
    lighter, darker = l1 < l2 ? [l2, l1] : [l1, l2]
    (lighter + 0.05) / (darker + 0.05)
  end

  def luminosity(hex)
    r, g, b = rgb(hex).map do |v|
      x = v / 255.0
      x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055)**2.4
    end
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end

  def rgb(hex)
    hex.match('^#?([a-f0-9]{1,2})([a-f0-9]{1,2})([a-f0-9]{1,2})$')[1..3].map { |v| (v.length == 1 ? "#{v}#{v}" : v).to_i(16) }
  end

  def adjust_color(hex, pct)
    amt = pct * 255
    r, g, b = rgb(hex)
    [r, g, b].map { |v|
      [255, [0, v + amt].max]
        .min
        .round
        .to_s(16)
        .rjust(2, '0')
    }.join('')
  end
end
