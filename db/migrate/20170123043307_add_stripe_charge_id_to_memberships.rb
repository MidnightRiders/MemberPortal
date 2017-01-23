class AddStripeChargeIdToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :stripe_charge_id, :string
    add_index :memberships, :stripe_charge_id, unique: true

    execute 'UPDATE memberships SET stripe_charge_id = info->\'stripe_charge_id\''
    execute 'UPDATE memberships SET info = info - \'stripe_charge_id\'::text'
  end

  def down
    execute 'UPDATE memberships SET info = COALESCE(info, hstore(\'\')) || hstore(\'stripe_charge_id\', stripe_charge_id)'

    remove_column :memberships, :stripe_charge_id
  end
end
