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

require 'spec_helper'

describe Player do
  describe 'validation' do
    subject(:player) { Player.new }
    it 'does not accept empty fields' do
      subject.should_not be_valid
      subject.errors.should include(:first_name, :last_name, :position, :number, :club)
    end
    it 'requires a valid club' do
      subject = FactoryGirl.build(:player)
      subject.club_id = 100
      subject.should_not be_valid
    end
    it 'validates proper record' do
      subject = FactoryGirl.build(:player)
      subject.should be_valid
    end
  end
end
