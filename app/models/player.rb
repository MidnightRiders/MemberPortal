class Player < ActiveRecord::Base
  attr_accessor :info

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Player positions sorted back-to-front for +sort+ comparison
  POSITIONS = {
    'GK' => 1,
    'D' => 2,
    'LB' => 3,
    'LD' => 3,
    'CB' => 4,
    'CD' => 4,
    'RD' => 5,
    'RB' => 6,
    'M' => 7,
    'CDM' => 8,
    'LM' => 9,
    'CM' => 10,
    'RM' => 11,
    'CAM' => 12,
    'F' => 13,
    'LW' => 14,
    'RW' => 15,
    'FW' => 16
  }.freeze
  validates :first_name, :last_name, :position, :number, :club, presence: true
  validates :position, inclusion: POSITIONS.keys

  belongs_to :club
  has_many :mot_m_firsts, -> { includes(:match) }, class_name: 'MotM', foreign_key: 'first_id'
  has_many :mot_m_seconds, -> { includes(:match) }, class_name: 'MotM', foreign_key: 'second_id'
  has_many :mot_m_thirds, -> { includes(:match) }, class_name: 'MotM', foreign_key: 'third_id'

  # Returns *Boolean*. Alias for <tt>!active?</tt>.
  def inactive?
    !active?
  end

  # Returns *Integer*. Scores Man of the Match voting for a player.
  # If no +match_id+ is provided, returns total scoring. Otherwise, scoring for that match.
  def mot_m_total(params = { season: Date.current.year })
    if params[:season]
      (mot_m_firsts.select { |x| x.match.season == params[:season] }.length * 3) + (mot_m_seconds.select { |x| x.match.season == params[:season] }.length * 2) + (mot_m_thirds.select { |x| x.match.season == params[:season] }.length * 1)
    else
      (mot_m_firsts.select { |x| x.match_id.in? [params[:match_id]].flatten }.length * 3) + (mot_m_seconds.select { |x| x.match_id.in? [params[:match_id]].flatten }.length * 2) + (mot_m_thirds.select { |x| x.match_id.in? [params[:match_id]].flatten }.length * 1)
    end
  end

  # Rewrites sorting to default to position-based sorting, from GK to FW
  def <=>(other)
    POSITIONS[position] <=> POSITIONS[other.position]
  end

  def self.mot_ms_for(matches)
    players = {}
    matches.each do |match|
      votes = {}
      match.mot_ms.each do |mot_m|
        { first_id: 3, second_id: 2, third_id: 1 }.each do |place, points|
          next if mot_m[place].nil?
          votes[mot_m[place]] ||= 0
          votes[mot_m[place]] += points
        end
      end
      votes = votes.to_a.group_by(&:last).to_a.sort_by(&:first).reverse
      winners = { first: votes[0]&.last || [], second: votes[1]&.last || [], third: votes[2]&.last || [] }
      winners.each do |place, set|
        set.each do |winner|
          players[winner[0]] ||= { first: 0, second: 0, third: 0 }
          players[winner[0]][place] += 1
        end
      end
    end
    players.to_a
      .sort_by { |_id, p| [p[:first] * 3 + p[:second] * 2 + p[:third], p[:first], p[:second], p[:third]] }.reverse
      .map { |id, p| Player.find_by(id: id).tap { |pl| pl&.info = { points: p[:first] * 3 + p[:second] * 2 + p[:third], breakdown: p } } }
      .reject(&:nil?)
  end
end
