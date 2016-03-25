class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :member_cost
      t.integer :non_member_cost
      t.boolean :active
      t.integer :stock
      t.text :description

      t.timestamps
    end
  end
end
