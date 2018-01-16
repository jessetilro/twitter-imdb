class AddImdbTitleIdToTwitterTweet < ActiveRecord::Migration[5.1]
  def change
    add_column :twitter_tweets, :imdb_title_id, :bigint
  end
end
