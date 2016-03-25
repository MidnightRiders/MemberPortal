class CreateProductOrders < ActiveRecord::Migration
  def change
    create_table :product_orders do |t|
      t.references :product, index: true
      t.references :order, index: true

      t.timestamps
    end
  end
end
