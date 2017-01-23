class AddStripeSubscriptionIdToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :stripe_subscription_id, :string, unique: true
    add_index :memberships, [:year, :stripe_subscription_id], unique: true

    execute 'UPDATE memberships SET stripe_subscription_id = info->\'stripe_subscription_id\''
    execute 'UPDATE memberships SET info = info - \'stripe_subscription_id\'::text'
  end

  def down
    execute 'UPDATE memberships SET info = COALESCE(info, hstore(\'\')) || hstore(\'stripe_subscription_id\', stripe_subscription_id)'

    remove_column :memberships, :stripe_subscription_id
  end
end
