require 'spec_helper'

describe Spree::UserMethods do
  let(:test_user) { create :user }

  describe 'Associations' do
    subject { test_user }

    it 'should have many promotion_rule_users' do
      is_expected.to have_many(:promotion_rule_users).with_foreign_key(:user_id).
        class_name('Spree::PromotionRuleUser').dependent(:destroy)
    end

    it 'should have many role_users' do
      is_expected.to have_many(:role_users).class_name('Spree::RoleUser').
        with_foreign_key(:user_id).dependent(:destroy)
    end
  end

  describe '#has_spree_role?' do
    subject { test_user.has_spree_role? name }

    let(:role) { Spree::Role.create(name: name) }
    let(:name) { 'test' }

    context 'with a role' do
      before { test_user.spree_roles << role }
      it { is_expected.to be_truthy }
    end

    context 'without a role' do
      it { is_expected.to be_falsy }
    end
  end

  describe '#last_incomplete_spree_order' do
    subject { test_user.last_incomplete_spree_order }

    context 'with an incomplete order' do
      let(:last_incomplete_order) { create :order, user: test_user }

      before do
        create(:order, user: test_user, created_at: 1.day.ago)
        create(:order, user: create(:user))
        last_incomplete_order
      end

      it { is_expected.to eq last_incomplete_order }
    end

    context 'without an incomplete order' do
      it { is_expected.to be_nil }
    end
  end
end
