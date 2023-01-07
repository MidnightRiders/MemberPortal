class AddPolls < ActiveRecord::Migration[7.0]
  def change
    create_table :polls do |t|
      t.string :title
      t.text :description
      t.datetime :start_time, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :end_time
      t.integer :multiple_choice, null: true

      t.timestamps precision: nil
    end

    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :title
      t.attachment :image

      t.timestamps precision: nil
    end

    create_table :poll_votes do |t|
      t.references :poll_option, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps precision: nil
    end
  end
end
