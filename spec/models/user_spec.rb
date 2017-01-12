# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  last_name              :string(255)
#  first_name             :string(255)
#  address                :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  postal_code            :string(255)
#  phone                  :integer
#  email                  :string(255)      default(""), not null
#  username               :string(255)      default(""), not null
#  member_since           :integer
#  created_at             :datetime
#  updated_at             :datetime
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

require 'spec_helper'

describe User do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }
    context 'for admin user' do
      let(:user) { FactoryGirl.create(:user, :admin) }
      it { should be_able_to(:manage, [Match, User, Player, Club]) }
      it { should be_able_to(:create, User) }
    end
    context 'for normal user' do
      let(:user) { FactoryGirl.create(:user) }
      it { should be_able_to(:manage, user) }
      it { should_not be_able_to(:manage, FactoryGirl.create(:user)) }
      it { should be_able_to(:show, FactoryGirl.create(:user)) }
      it { should_not be_able_to(:manage, [Club, Player, Match]) }
      it { should be_able_to(:index, Match) }
      it { should_not be_able_to(:index, [Player, Club, User]) }
    end
    context 'for no user' do
      it { should be_able_to(:create, :Registration) }
      it { should_not be_able_to(:view, FactoryGirl.create(:user)) }
      it { should_not be_able_to(:index, [Match, User, Player, Club]) }
    end
  end
  describe 'validation' do
    subject(:user) { User.new }
    it 'should not be valid with missing fields' do
      expect(subject).to_not be_valid
      expect(subject.errors).to include(:first_name, :last_name, :username, :password)
    end
    it 'should not accept an invalid member_since year' do
      user = FactoryGirl.build(:user)
      user.member_since = 1990
      expect(user).to_not be_valid
      user.member_since = Date.current.year + 1
      expect(user).to_not be_valid
      user.member_since = Date.current.year
      expect(user).to be_valid
    end
  end
  describe 'class methods' do
    describe 'import' do

      let(:users_hash) {
        [{ first_name: 'Quentin', last_name: 'Coldwater', email: 'fillory.fan@gmail.com', membership_type: 'Individual', address: %{123 Test Ln\nApt 412}, city: 'Brooklyn', state: 'NY', postal_code: '11201' },
          { first_name: 'Alice', last_name: 'Quinn', email: 'niffin@yahoo.com', membership_type: 'Family', address: '12 Blah Ct', city: 'Brooklyn', state: 'NY', postal_code: '11202' },
          { first_name: 'Eliot', last_name: 'Waugh', email: 'high.king@brakebills.com', membership_type: 'Relative', address: '143b Fliff', city: 'Flatbush', state: 'NY', postal_code: '11203' }]
      }
      let!(:admin_user) { FactoryGirl.create(:user, :admin) }

      it 'imports Individual and Family users' do
        expect { User.import(users_hash) }.to change(User, :count).by(2)
      end
      it 'grants memberships to members without' do
        expect { User.import(users_hash, override_id: admin_user.id) }.to change(Membership, :count).by(2)
      end
      it 'doesn\'t grant memberships to members with' do
        user = users_hash.select { |u| u[:membership_type] != 'Relative' }.sample
        FactoryGirl.create(:user).tap { |u| u.email = user[:email] }.save

        expect { User.import(users_hash, override_id: admin_user.id) }.to change(Membership, :count).by(1)
      end
    end
  end
end
