class Player < ActiveRecord::Base
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

  def motm_total
    (motm_firsts.length * 3) + (motm_seconds.length * 2) + (motm_thirds.length * 1)
  end

  def <=> (other)
    POSITIONS[self.position] <=> POSITIONS[other.position]
  end
end
