class AddFlagsToTwitterUser < ActiveRecord::Migration[5.1]
  def change
    add_column :twitter_users, :has_imdb_ratings, :boolean, default: false
    add_column :twitter_users, :fetched_tweets, :boolean, default: false
  end
end
