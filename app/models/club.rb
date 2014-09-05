# == Schema Information
#
# Table name: clubs
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  conference         :string(255)
#  primary_color      :integer
#  secondary_color    :integer
#  accent_color       :integer
#  abbrv              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  crest_file_name    :string(255)
#  crest_content_type :string(255)
#  crest_file_size    :integer
#  crest_updated_at   :datetime
#

class Club < ActiveRecord::Base
  CONFERENCES = %w(east west)

  has_attached_file :crest,
                    storage: :ftp,
                    path: '/public_html/member_portal/:class/:attachment/:id/:style_:filename',
                    url: '/member_portal/:class/:attachment/:id/:style_:filename',
                    ftp_servers: [{
                        host: 'ftp.midnightriders.com',
                        user: 'midnigi3',
                        password: 'V9NP+rs96FRcZ-S',
                        passive: true
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

  # Returns *Array* of +Matches+ involving the club.
  def matches
    Match.where('home_team_id = :id OR away_team_id = :id', id: id).order('kickoff ASC')
  end

  # Returns +Match+ or *Array* of +Matches+, depending on +n+, before +time+ (defaults to now).
  def previous_matches(n=1,time=Time.now)
    matches.reverse.select{|x| x.kickoff < time}.first(n)
  end

  # Returns +Match+ or *Array* of +Matches+, depending on +n+, after +time+ (defaults to now).
  def next_matches(n=1,time=Time.now)
    matches.select{|x| x.kickoff >= time}.first(n)
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
    matches.select{|x| x.winner == self }
  end

  # Returns *Array* of +Matches+ that the club has lost.
  def losses
    matches.select{|x| x.loser == self }
  end

  # Returns *Array* of +Matches+ that the club has drawn.
  def draws
    matches.select{|x| x.result == :draw }
  end

  # Returns *String* in format of "W-L-D".
  def record
    "#{wins.size}-#{losses.size}-#{draws.size}"
  end

  # Sets color methods which return *String*s.
  %w(primary secondary accent).each do |x|
    define_method("#{x}_color=") do |val|
      write_attribute("#{x}_color", val.to_i(16))
    end
    define_method("#{x}_color") do
      read_attribute("#{x}_color").to_s(16).rjust(6,'0') unless read_attribute("#{x}_color").nil?
    end
  end

  # Returns *String*. Color method that falls back to +accent_color+ if +secondary_color+ is white.
  def dark_compliment
    secondary_color == 'ffffff' ? accent_color : secondary_color
  end
end
