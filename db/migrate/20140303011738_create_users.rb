class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :type_id
      t.string :last_name
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :phone
      t.string :email,              :null => false, :default => ""
      t.string :member_since

      t.timestamps
    end
  end
end
