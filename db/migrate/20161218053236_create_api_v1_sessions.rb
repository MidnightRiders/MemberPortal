class CreateApiV1Sessions < ActiveRecord::Migration
  def change
    create_table :api_v1_sessions do |t|
      t.references :user, foreign_key: true, index: true
      t.string :auth_token, index: true
      t.string :requesting_ip
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
