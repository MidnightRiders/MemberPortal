class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :title
      t.string :preheader
      t.text :content
      t.text :featured_shop
      t.json :game
      t.json :viewings

      t.timestamps
    end
  end
end
