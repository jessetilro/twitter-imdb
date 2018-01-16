class TwitterUser < ApplicationRecord
  API_COPY = %i[id name screen_name location url description translator_type protected verified followers_count friends_count listed_count favourites_count statuses_count utc_offset time_zone geo_enabled lang contributors_enabled is_translator profile_background_color profile_background_image_url profile_background_image_url_https profile_background_tile profile_link_color profile_sidebar_border_color profile_sidebar_fill_color profile_text_color profile_use_background_image profile_image_url profile_image_url_https profile_banner_url default_profile default_profile_image following follow_request_sent notifications]
  API_MAPPING = {
    t_id: :id,
    t_created_at: :created_at
  }
  RATINGS_RATIO_SQL = '(ratings_count::float / twitter_tweets_count)'

  has_many :twitter_tweets
  has_one :movietweetings_user, foreign_key: :twitter_id
  has_many :ratings

  scope :having_imdb_ratings, lambda {
    joins_imdb_ratings.distinct
  }
  scope :joins_imdb_ratings, lambda {
    joins(:twitter_tweets).where('twitter_tweets.text LIKE \'%I rated%\' AND twitter_tweets.entities_hashtags ILIKE \'%imdb%\'')
  }

  scope :in_movietweetings_users, lambda {
    joins(:movietweetings_user)
  }

  scope :english, lambda {
    where('twitter_users.lang = \'en\' AND twitter_tweets.lang = \'en\'')
  }

  scope :having_ratings, lambda {
    where('ratings_count > 0')
  }

  scope :relevant, lambda {
    where('twitter_tweets_count >= 1000 AND ratings_count > 0')
  }

  scope :ratings_ratio, lambda {
    select("#{RATINGS_RATIO_SQL} AS ratings_ratio")
  }

  scope :with_ratings_ratio, lambda {
    select('*').ratings_ratio
  }

  scope :already_fetched, -> { where(fetched_tweets: true) }
  scope :not_yet_fetched, -> { where(fetched_tweets: false) }

  scope :with_missing_tweets_count, lambda {
    max_achievable = "LEAST(twitter_users.statuses_count, #{TwitterService::MAX_TWEET_COUNT_PER_USER})"
    actual = "COUNT(twitter_tweets.id)"
    group('twitter_users.id')
      .joins(:twitter_tweets)
      .select("GREATEST(#{max_achievable} - #{actual}, 0) AS missing_tweets_count, twitter_users.*")
  }

  def ratings_ratio
    read_attribute(:ratings_ratio) || ratings_count / twitter_tweets_count.to_f
  end

  def self.get_api_value(f_api, object)
    object.try(f_api) || object.try("#{f_api}?")
  end

  def self.save_from_api!(object)
    return unless object.is_a?(Twitter::User)

    attributes_hash = API_COPY.map { |f| [f, get_api_value(f, object)] }.to_h
    attributes_hash.merge! API_MAPPING.map { |f, f_api| [f, get_api_value(f_api, object)] }.to_h

    find_or_initialize_by(id: attributes_hash[:id])
      .tap do |x|
        x.assign_attributes(attributes_hash)
        x.save!
      end
  end
end
