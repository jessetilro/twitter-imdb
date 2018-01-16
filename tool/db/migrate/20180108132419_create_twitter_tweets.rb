class CreateTwitterTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :twitter_tweets, id: false do |t|
      t.bigint :id, primary_key: true, index: true, limit: 8
      t.bigint :t_id, index: true, limit: 8

      t.references :twitter_user, limit: 8

      t.text :text, index: true
      t.string :source

      t.datetime :t_created_at

      t.boolean :truncated
      t.bigint :in_reply_to_status_id, limit: 8
      t.bigint :in_reply_to_user_id, limit: 8
      t.string :in_reply_to_screen_name

      t.string :geo
      t.string :coordinates
      t.string :place
      t.string :contributors
      t.boolean :is_quote_status

      t.integer :quote_count, limit: 8
      t.integer :reply_count, limit: 8
      t.integer :retweet_count, limit: 8
      t.integer :favorite_count, limit: 8

      t.text :entities_hashtags
      t.text :entities_urls

      t.boolean :favorited
      t.boolean :retweeted
      t.boolean :possibly_sensitive
      t.string :filter_level
      t.string :lang
      t.integer :timestamp_ms, limit: 8

      t.timestamps
    end
  end
end
