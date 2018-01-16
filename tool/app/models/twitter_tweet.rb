class TwitterTweet < ApplicationRecord
  API_COPY = %i[id text source truncated in_reply_to_status_id in_reply_to_user_id in_reply_to_screen_name geo coordinates place contributors is_quote_status quote_count reply_count retweet_count favorite_count favorited retweeted possibly_sensitive filter_level lang timestamp_ms]
  API_MAPPING = {
    t_id: :id,
    t_created_at: :created_at
  }

  RATING_TEXT_PATTERN = /.*I rated.*[^0-9]((?<rating>[0-9]{1,2}|[0-9]\.[0-9])((| )\/| out( of|) )10).*#IMDb.*/im

  belongs_to :twitter_user, counter_cache: true
  has_one :rating

  scope :imdb_ratings, lambda {
    where('twitter_tweets.text LIKE \'%I rated%\' AND twitter_tweets.entities_hashtags ILIKE \'%imdb%\'')
  }

  scope :accurate_imdb_ratings, lambda {
    where("text ~* \'#{RATING_TEXT_PATTERN.source.sub('?<rating>', '')}\'")
  }

  scope :accurate_not_imdb_ratings, lambda {
    where.not("text ~* \'#{RATING_TEXT_PATTERN.source.sub('?<rating>', '')}\'")
  }

  scope :accurate_imdb_ratings2, lambda {
    where('text SIMILAR TO \'%I rated%(([0-9]{1,2}|[0-9].[0-9])/10|([0-9]{1,2}|[0-9].[0-9]) out( of|) 10)%\'')
  }

  scope :relevant, lambda {
    joins(:twitter_user).where('twitter_users.twitter_tweets_count >= 1000 AND twitter_users.ratings_count > 0').distinct
  }

  def derive_rating
    Rating.new(
      twitter_tweet_id: id,
      twitter_user_id: twitter_user_id,
      imdb_title_id: derive_imdb_title_id,
      rating: derive_rating_score
    )
  end

  def derive_imdb_title_id
    entities_urls.to_s.split(',').each do |url|
      id = ImdbTitle.id_from_url(url)
      return id if id.present?
    end
  end

  def derive_rating_score
    match = RATING_TEXT_PATTERN.match(text)
    match[:rating].to_f.round if match.present?
  end

  def self.get_api_value(f_api, object)
    object.try(f_api) || object.try("#{f_api}?")
  end

  def self.save_from_api!(object)
    return unless object.is_a?(Twitter::Tweet)

    attributes_hash = API_COPY.map { |f| [f, get_api_value(f, object)] }.to_h
    attributes_hash.merge! API_MAPPING.map { |f, f_api| [f, get_api_value(f_api, object)] }.to_h

    attributes_hash.merge!({
      entities_urls: object.urls.map(&:expanded_url).map(&:to_s).join(','),
      entities_hashtags: object.hashtags.map(&:text).join(',')
    })

    user = TwitterUser.save_from_api!(object.user)
    attributes_hash[:twitter_user_id] = user.id if user.present?

    find_or_initialize_by(id: attributes_hash[:id])
      .tap do |x|
        x.assign_attributes(attributes_hash)
        x.text.delete!("\u0000")
        x.save!
      end
  end
end
