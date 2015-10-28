class CreatePostViews < ActiveRecord::Migration
  def change
    create_table :post_views do |t|
      t.references :user
      t.references :post, polymorphic: true

      t.timestamps
    end

    add_index :post_views, [ :user_id, :post_id, :post_type ], unique: true
  end
end
