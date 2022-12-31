require 'rails_helper'
require 'support/shared_examples/purchaser'

RSpec.describe User do
  describe 'scopes' do
    pending 'members'
    pending 'non_members'
  end

  describe 'validation' do
    subject(:user) { User.new }
    it 'should not be valid with missing fields' do
      expect(subject).to_not be_valid
      expect(subject.errors).to include(:first_name, :last_name, :username, :password)
    end
    it 'should not accept an invalid member_since year' do
      user = FactoryBot.build(:user)
      user.member_since = 1990
      expect(user).to_not be_valid
      user.member_since = Date.current.year + 1
      expect(user).to_not be_valid
      user.member_since = Date.current.year
      expect(user).to be_valid
    end
  end

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'for admin user' do
      let(:user) { FactoryBot.create(:user, :admin) }
      it 'can manage Matches, Users, Players, Clubs' do
        expect(ability).to be_able_to(:manage, [Match, User, Player, Club])
      end
      it 'can create Users' do
        expect(ability).to be_able_to(:create, User)
      end
    end

    context 'for normal user' do
      let(:user) { FactoryBot.create(:user) }
      it 'can manage itself' do
        expect(ability).to be_able_to(:manage, user)
      end
      it "can't manage another user" do
        expect(ability).not_to be_able_to(:manage, FactoryBot.create(:user))
      end
      it 'can show another user' do
        expect(ability).to be_able_to(:show, FactoryBot.create(:user))
      end
      it "can't manage Clubs, Players, Matches" do
        expect(ability).not_to be_able_to(:manage, [Club, Player, Match])
      end
      it 'can index Matches' do
        expect(ability).to be_able_to(:index, Match)
      end
      it "can't index Players, Clubs, or Users" do
        expect(ability).not_to be_able_to(:index, [Player, Club, User])
      end
    end

    context 'for no user' do
      it "can't create a Registration" do
        expect(ability).to be_able_to(:create, :Registration)
      end
      it "can't view any user" do
        expect(ability).not_to be_able_to(:view, FactoryBot.create(:user))
      end
      it "can't index Matches, Users, Players, Clubs" do
        expect(ability).not_to be_able_to(:index, [Match, User, Player, Club])
      end
    end
  end

  describe 'generate_temporary_password!' do
    context 'new user' do
      let(:user) { FactoryBot.build(:user).tap { |u| u.password = nil } }

      it 'generates a password' do
        expect { user.generate_temporary_password! }.to change(user, :password)
      end

      it 'returns the generated temp password' do
        expect(user.generate_temporary_password!).to be_a(String)
      end
    end

    context 'existing user' do
      let(:user) { FactoryBot.create(:user) }

      it 'does not generate a password' do
        expect { user.generate_temporary_password! }.not_to change(user, :password)
      end

      it 'returns false' do
        expect(user.generate_temporary_password!).to be_falsey
      end
    end
  end

  it_behaves_like 'Commerce::Purchaser' do
    let(:purchaser) { FactoryBot.create(:user) }
  end

  pending 'current_privileges'
  pending 'privilege?'
  pending 'leadership_or_admin?'
  pending 'current_membership'
  pending 'current_family'
  pending 'current_member?'
  pending 'family_invitation'
  pending 'invited_to_family?'
  pending 'pick_for'
  pending 'pick_result'
  pending 'gravatar'
  pending 'generate_username!'
  pending 'grant_membership!'
  pending 'phone='
  pending 'to_param'

  describe 'class methods' do
    describe 'import' do
      let(:users_hash) {
        [
          { first_name: 'Quentin', last_name: 'Coldwater', email: 'fillory.fan@gmail.com', membership_type: 'Individual', address: %(123 Test Ln\nApt 412), city: 'Brooklyn', state: 'NY', postal_code: '11201' },
          { first_name: 'Alice', last_name: 'Quinn', email: 'niffin@yahoo.com', membership_type: 'Family', address: '12 Blah Ct', city: 'Brooklyn', state: 'NY', postal_code: '11202' },
          { first_name: 'Eliot', last_name: 'Waugh', email: 'high.king@brakebills.com', membership_type: 'Relative', address: '143b Fliff', city: 'Flatbush', state: 'NY', postal_code: '11203' }
        ]
      }
      let(:improper_users_hash) {
        [
          { first_name: 'Quentin', last_name: 'Coldwater', email: 'fillory.fan@gmail.com', membership_type: 'Individual', address: %(123 Test Ln\nApt 412), city: 'Brooklyn', state: 'NY', postal_code: '11201' },
          { first_name: 'Eliot', last_name: 'Waugh', email: 'high.king@brakebills.com', membership_type: 'Relative', address: '143b Fliff', city: 'Flatbush', state: 'NY', postal_code: '11203' },
          { first_name: 'Alice', last_name: 'Quinn', email: 'niffin@yahoo.com', membership_type: 'Family', address: '12 Blah Ct', city: 'Brooklyn', state: 'NY', postal_code: '11202' }
        ]
      }
      let!(:admin_user) { FactoryBot.create(:user, :admin) }

      it 'imports Individual and Family users' do
        expect { User.import(users_hash, override_id: admin_user.id) }.to change(User, :count).by(3)
      end
      it 'grants memberships to members without current memberships' do
        expect { User.import(users_hash, override_id: admin_user.id) }.to change(Membership, :count).by(3)
      end
      it "doesn't grant memberships to members with current memberships" do
        user = users_hash.select { |u| u[:membership_type] != 'Relative' }.sample
        FactoryBot.create(:user).tap { |u| u.email = user[:email] }.save!

        expect { User.import(users_hash, override_id: admin_user.id) }.to change(Membership, :count).by(2)
      end
      it 'associates Relatives with their preceding Families' do
        User.import(users_hash, override_id: admin_user.id)

        expect(User.find_by(first_name: 'Eliot', last_name: 'Waugh').current_membership.family).to eq(User.find_by(first_name: 'Alice', last_name: 'Quinn').current_membership)
      end
      it "doesn't create Users for Relatives if they don't follow a Family" do
        expect { User.import(improper_users_hash, override_id: admin_user.id) }.to change(User, :count).by(2)
      end
      it "doesn't create Relatives if they don't follow a Family" do
        expect { User.import(improper_users_hash, override_id: admin_user.id) }.to change(Membership, :count).by(2)
      end
    end

    describe 'from_hash' do
      let(:hash) { FactoryBot.build(:user).attributes.slice(*User::IMPORTABLE_ATTRIBUTES) }

      it 'creates a new User with a valid hash of new information' do
        expect { User.from_hash(hash) }.to change(User, :count).by(1)
      end

      it "doesn't create a new record if the User exists" do
        User.from_hash(hash)

        expect { User.from_hash(hash) }.not_to change(User, :count)
      end

      it 'updates an existing User' do
        user = User.from_hash(hash).tap { |u| u.update_attribute(:last_name, 'Weird-name-not-in-Ffaker') }

        expect { User.from_hash(hash) }.to change { user.reload.last_name }
      end
    end

    describe 'to_csv' do
      before(:each) {
        User.create(
          [
            { username: 'quentin', password: 'password', first_name: 'Quentin', last_name: 'Coldwater', email: 'fillory.fan@gmail.com', address: %(123 Test Ln\nApt 412), city: 'Brooklyn', state: 'NY', postal_code: '11201' },
            { username: 'alice', password: 'password', first_name: 'Alice', last_name: 'Quinn', email: 'niffin@yahoo.com', address: '12 Blah Ct', city: 'Brooklyn', state: 'NY', postal_code: '11202' },
            { username: 'eliot', password: 'password', first_name: 'Eliot', last_name: 'Waugh', email: 'high.king@brakebills.com', address: '143b Fliff', city: 'Flatbush', state: 'NY', postal_code: '11203' }
          ]
        )
      }

      let(:csv) { User.all.to_csv }

      it 'outputs headers' do
        expect(csv.split("\n").first).to eq("Id,Last Name,First Name,Address,City,State,Postal Code,Phone,Email,Username,Member Since,Last Sign In At,Country,Current Member,#{Date.current.year} Membership Type")
      end

      it 'outputs users' do
        expect(csv).to include("Coldwater,Quentin,\"123 Test Ln\nApt 412\",Brooklyn,NY")
        expect(csv).to include('Quinn,Alice,12 Blah Ct,Brooklyn,NY')
        expect(csv).to include('Waugh,Eliot,143b Fliff,Flatbush,NY')
      end

      it 'only outputs selected users' do
        brooklyn_csv = User.where(city: 'Brooklyn').to_csv
        expect(brooklyn_csv).to include('Coldwater,Quentin')
        expect(brooklyn_csv).to include('Quinn,Alice')
        expect(brooklyn_csv).not_to include('Waugh,Eliot')
      end
    end
  end
end
