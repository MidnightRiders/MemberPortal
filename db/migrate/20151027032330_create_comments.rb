class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :discussion, index: true
      t.references :user, index: true
      t.text :content
      t.references :comment, index: true

      t.timestamps
    end

    add_index :comments, :created_at
    add_index :comments, [ :discussion_id, :created_at ]
  end
end
