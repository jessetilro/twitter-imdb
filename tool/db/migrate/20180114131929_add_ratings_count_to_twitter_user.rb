class AddRatingsCountToTwitterUser < ActiveRecord::Migration[5.1]
  def change
    add_column :twitter_users, :ratings_count, :integer
  end
end
