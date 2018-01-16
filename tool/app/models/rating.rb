class Rating < ApplicationRecord
  belongs_to :twitter_tweet
  belongs_to :twitter_user, counter_cache: true
  belongs_to :imdb_title

  scope :correct, -> { where(rating: 1..10) }
  scope :incorrect, -> { where.not(rating: 1..10) }

  scope :relevant, lambda {
    joins(:twitter_user).where('twitter_users.ratings_count > 0 AND twitter_users.twitter_tweets_count >= 1000').distinct
  }

  def self.import_from_tweets!
    existing = Rating.pluck(:twitter_tweet_id)
    tweets = TwitterTweet
      .accurate_imdb_ratings
      .where.not(id: existing).to_a

    while tweets.present?
      batch = tweets.shift(1000)
      ratings = batch.map do |t|
        rating = t.derive_rating
        byebug if rating.blank?
        rating
      end.compact
      Rating.import(ratings, validate: false)
    end
  end

  def self.fix_incorrect_ratings!
    tweets = TwitterTweet
      .joins(:rating).where(ratings: { rating: nil })
      .includes(:twitter_tweet)
    tweets.each do |tweet|
      tweet.rating.update(rating: tweet.derive_rating.rating)
    end
  end
end
