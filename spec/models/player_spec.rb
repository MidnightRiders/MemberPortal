require 'rails_helper'

describe Player do
  describe 'validation' do
    subject(:player) { Player.new }
    it 'does not accept empty fields' do
      expect(subject).to_not be_valid
      expect(subject.errors).to include(:first_name, :last_name, :position, :number, :club)
    end
    it 'requires a valid club' do
      subject = FactoryBot.build(:player)
      subject.club_id = 100
      expect(subject).to_not be_valid
    end
    it 'validates proper record' do
      subject = FactoryBot.build(:player)
      expect(subject).to be_valid
    end
  end

  describe 'mot_m_total' do
    pending 'returns total MotM votes for player'
    pending 'returns total for previous year'
  end

  describe 'class methods' do
    describe 'mot_ms_for' do
      pending 'returns hash of players with MotM votes'
    end
  end
end
