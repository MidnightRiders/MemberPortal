class AddNumberToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :number, :integer, limit: 1
  end
end
