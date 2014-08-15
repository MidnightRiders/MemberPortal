class Player < ActiveRecord::Base

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

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
  has_many :motm_firsts, class_name: 'MotM', foreign_key: 'first_id'
  has_many :motm_seconds, class_name: 'MotM', foreign_key: 'second_id'
  has_many :motm_thirds, class_name: 'MotM', foreign_key: 'third_id'

  def inactive?
    !active?
  end

  def mot_m_total(match_id = nil)
    if match_id
      (motm_firsts.where(match_id: match_id).length * 3) + (motm_seconds.where(match_id: match_id).length * 2) + (motm_thirds.where(match_id: match_id).length * 1)
    else
      (motm_firsts.length * 3) + (motm_seconds.length * 2) + (motm_thirds.length * 1)
    end
  end

  def <=> (other)
    POSITIONS[self.position] <=> POSITIONS[other.position]
  end
end
