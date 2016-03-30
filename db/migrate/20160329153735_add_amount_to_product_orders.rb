class AddAmountToProductOrders < ActiveRecord::Migration
  def change
    add_column :product_orders, :amount, :integer, default: 1, null: false
  end
end
