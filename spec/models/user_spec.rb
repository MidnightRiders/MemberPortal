require 'spec_helper'

describe User do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }
    context 'for admin user' do
      let(:user) { FactoryGirl.create(:user,:admin) }
      it{ should be_able_to(:manage,[Match,User,Player,Club])}
    end
    context 'for normal user' do
      let(:user) { FactoryGirl.create(:user) }
      it{ should be_able_to(:manage,user) }
      it{ should_not be_able_to(:manage, FactoryGirl.create(:user) ) }
      it{ should be_able_to(:show,FactoryGirl.create(:user) ) }
      it{ should_not be_able_to(:manage, [Club,Player,Match] ) }
      it{ should be_able_to(:index,Match) }
      it{ should_not be_able_to(:index,[Player,Club,User]) }
    end
    context 'for no user' do
      it{ should be_able_to(:create,User) }
      it{ should_not be_able_to(:view,FactoryGirl.create(:user)) }
      it{ should_not be_able_to(:index,[Match,User,Player,Club]) }
    end
  end
  describe 'validation' do
    subject(:user) { User.new }
    it 'should not be valid with missing fields' do
      subject.should_not be_valid
      subject.errors.should include(:first_name, :last_name, :username, :password)
    end
    it 'should not accept an invalid member_since year' do
      user = FactoryGirl.build(:user)
      user.member_since = 1990
      user.should_not be_valid
      user.member_since = 2015
      user.should_not be_valid
      user.member_since = Date.today.year
      user.should be_valid
    end
  end
end
