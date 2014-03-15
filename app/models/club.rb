class Club < ActiveRecord::Base
  CONFERENCES = %w(east west)

  has_attached_file :crest,
                    storage: :ftp,
                    path: '/public_html/member_portal/:class/:attachment/:id/:style_:filename',
                    url: '/member_portal/:class/:attachment/:id/:style_:filename',
                    ftp_servers: [{
                        host: 'ftp.midnightriders.com',
                        user: 'midnigi3',
                        password: 'V9NP+rs96FRcZ-S'
                    }],
                    styles: {
                        thumb: '100x100>',
                        standard: '250x250>'
                    }

  validates :name, :abbrv, :primary_color, :secondary_color, :accent_color, presence: true
  validates :name, :abbrv, uniqueness: true
  validates :conference, inclusion: CONFERENCES, allow_blank: false
  validates :primary_color, :secondary_color, :accent_color, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 'ffffff'.to_i(16) }
  validates_attachment :crest, content_type: { :content_type => ['image/jpg', 'image/gif', 'image/png'] }

  has_many :home_matches, class_name: 'Match', foreign_key: 'home_team_id'
  has_many :away_matches, class_name: 'Match', foreign_key: 'away_team_id'

  has_many :players

  def matches
    (home_matches + away_matches).sort_by(&:kickoff)
  end

  def previous_matches(n=1,time=Time.now)
    matches.select{|x| x.kickoff < time}.first(n)
  end
  def next_matches(n=1,time=Time.now)
    matches.select{|x| x.kickoff >= time}.first(n)
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

  def wins
    matches.select{|x| x.complete? && x.winner == self }
  end

  def losses
    matches.select{|x| x.complete? && x.loser == self }
  end

  def draws
    matches.select{|x| x.complete? && x.result == :draw }
  end

  def record
    "#{wins.count}-#{losses.count}-#{draws.count}"
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
