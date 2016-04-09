class AddCountryToUser < ActiveRecord::Migration
  def up
    add_column :users, :country, :string

    User.where.not(postal_code: nil).each do |user|
      if user.postal_code =~ /^\d{5}([\- ]\d{4})?$/
        user.update_attribute(:country, 'USA')
      end
    end
  end

  def down
    remove_column :users, :country, :string
  end
end
