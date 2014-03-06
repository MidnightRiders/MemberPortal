class Player < ActiveRecord::Base
  POSITIONS = {
      'GK' => 1,
      'LB' => 2,
      'LD' => 2,
      'CB' => 3,
      'CD' => 3,
      'RD' => 4,
      'RB' => 4,
      'CDM' => 5,
      'LM' => 6,
      'CM' => 7,
      'RM' => 8,
      'CAM' => 9,
      'LW' => 10,
      'RW' => 11,
      'FW' => 12
  }
  validates :first_name, :last_name, :position, :number, presence: true
  validates :club, associated: true
  validates :position, inclusion: POSITIONS.keys

  belongs_to :club

  def <=> (other)
    POSITIONS[self.position] <=> POSITIONS[other.position]
  end
end
