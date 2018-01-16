class CreateTwitterUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :twitter_users, id: false do |t|
      t.bigint :id, primary_key: true, index: true, limit: 8
      t.bigint :t_id, index: true, limit: 8

      t.string :name
      t.string :screen_name, index: true
      t.string :location
      t.string :url
      t.text :description
      t.string :translator_type
      t.boolean :protected
      t.boolean :verified
      t.integer :followers_count, limit: 8
      t.integer :friends_count, limit: 8
      t.integer :listed_count, limit: 8
      t.integer :favourites_count, limit: 8
      t.integer :statuses_count, limit: 8
      t.string :utc_offset
      t.string :time_zone
      t.boolean :geo_enabled
      t.string :lang
      t.boolean :contributors_enabled
      t.boolean :is_translator
      t.string :profile_background_color
      t.string :profile_background_image_url
      t.string :profile_background_image_url_https
      t.boolean :profile_background_tile
      t.string :profile_link_color
      t.string :profile_sidebar_border_color
      t.string :profile_sidebar_fill_color
      t.string :profile_text_color
      t.boolean :profile_use_background_image
      t.string :profile_image_url
      t.string :profile_image_url_https
      t.string :profile_banner_url
      t.boolean :default_profile
      t.boolean :default_profile_image
      t.boolean :following
      t.boolean :follow_request_sent
      t.string :notifications

      t.datetime :t_created_at

      t.timestamps
    end
  end
end
