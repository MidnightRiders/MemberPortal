class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title
      t.text :content
      t.references :match, index: true
      t.references :user, index: true

      t.timestamps
    end

    add_index :discussions, :created_at
  end
end
