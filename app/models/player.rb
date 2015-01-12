# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  club_id    :integer
#  position   :string(255)
#  created_at :datetime
#  updated_at :datetime
#  number     :integer
#  active     :boolean          default(TRUE)
#

class Player < ActiveRecord::Base

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Player positions sorted back-to-front for +sort+ comparison
  POSITIONS = {
      'GK' => 1,
      'D'  => 2,
      'LB' => 3,
      'LD' => 3,
      'CB' => 4,
      'CD' => 4,
      'RD' => 5,
      'RB' => 6,
      'M'  => 7,
      'CDM' => 8,
      'LM' => 9,
      'CM' => 10,
      'RM' => 11,
      'CAM' => 12,
      'F'  => 13,
      'LW' => 14,
      'RW' => 15,
      'FW' => 16
  }
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
      (mot_m_firsts.select{|x| x.match.season == params[:season]}.length * 3) + (mot_m_seconds.select{|x| x.match.season == params[:season]}.length * 2) + (mot_m_thirds.select{|x| x.match.season == params[:season]}.length * 1)
    else
      (mot_m_firsts.select{|x| x.match_id.in? [params[:match_id]].flatten }.length * 3) + (mot_m_seconds.select{|x| x.match_id.in? [params[:match_id]].flatten }.length * 2) + (mot_m_thirds.select{|x| x.match_id.in? [params[:match_id]].flatten }.length * 1)
    end
  end

  # Rewrites sorting to default to position-based sorting, from GK to FW
  def <=> (other)
    POSITIONS[self.position] <=> POSITIONS[other.position]
  end
end
