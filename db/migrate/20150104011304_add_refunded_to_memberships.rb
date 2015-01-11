class AddRefundedToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :refunded, :text, default: nil
  end
end
