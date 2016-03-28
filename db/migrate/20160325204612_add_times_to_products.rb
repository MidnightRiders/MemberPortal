class AddTimesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :available_start, :datetime
    add_column :products, :available_end, :datetime
  end
end
