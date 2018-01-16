class FixHashtagsUrls < ActiveRecord::Migration[5.1]
  def change
    rename_column :twitter_tweets, :entities_hashtags, :entities_urls_temp
    rename_column :twitter_tweets, :entities_urls, :entities_hashtags
    rename_column :twitter_tweets, :entities_urls_temp, :entities_urls
  end
end
