class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.bigint :twitter_tweet_id
      t.bigint :twitter_user_id, index: true
      t.bigint :imdb_title_id, index: true
      t.integer :rating, index: true

      t.timestamps

      t.index :twitter_tweet_id, unique: true
    end
  end
end
