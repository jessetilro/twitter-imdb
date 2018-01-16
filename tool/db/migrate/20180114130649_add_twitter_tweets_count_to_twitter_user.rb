class AddTwitterTweetsCountToTwitterUser < ActiveRecord::Migration[5.1]
  def change
    add_column :twitter_users, :twitter_tweets_count, :integer
  end
end
