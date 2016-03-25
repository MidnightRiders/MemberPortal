class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :user, index: true
      t.hstore :info
      t.timestamp :completed_at
      t.boolean :fulfilled, default: false

      t.timestamps
    end
  end
end
