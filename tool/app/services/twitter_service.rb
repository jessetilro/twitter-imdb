class TwitterService
  MAX_TWEET_COUNT_PER_USER = 3200
  SECRET_FIELDS = [:consumer_key, :consumer_secret, :access_token, :access_token_secret]

  def initialize(secrets = {})
    @secrets = secrets.select { |k, _| SECRET_FIELDS.include?(k) }
    # set unspecified secrets to the value specified in application secrets
    SECRET_FIELDS.each do |secret|
      @secrets[secret] ||= Rails.application.secrets.send("twitter_#{secret}")
    end
  end

  def stream_imdb_ratings
    streaming_client.filter(track: '#imdb') do |object|
      puts "#{object.id}: #{object.text}" if object.is_a?(Twitter::Tweet)
      TwitterTweet.save_from_api!(object)
    end
  end

  def search_imdb_ratings
    rest_client.search('"I rated" #imdb', result_type: 'mixed', count: 100, include_entities: true).each do |object|
      TwitterTweet.save_from_api!(object)
    end
  end

  def stream_rotten_tomatoes
    streaming_client.filter(track: '#rottentomatoes') do |object|
      puts "#{object.id}: #{object.text}" if object.is_a?(Twitter::Tweet)
      TwitterTweet.save_from_api!(object)
    end
  end

  def fetch_user(id_or_screen_name)
    TwitterUser.save_from_api!(rest_client.user(id_or_screen_name))
  end

  def fetch_user_tweets(user, options = {})
    user = TwitterUser.find_or_initialize_by(id: user) if user.is_a?(Numeric)
    user.fetched_tweets = true
    user.save!
    LoggerService.log("fetching up to 3200 tweets of #{user.id} (#{user.try(:screen_name)})")

    max_id = options[:max_id]
    results = []
    options = {
      count: 200,
      include_rts: true
    }.merge(options)
    first = true
    while (max_id.blank? || results.present? || first)
      first = false
      begin
        o = options
        o[:max_id] = max_id if max_id.present?
        results = rest_client.user_timeline(user.id, o)
        results.each do |object|
          t = TwitterTweet.save_from_api!(object)
          # if t.lang != 'en' # if not english, abandon this user
          #   puts 'found a tweet that is not in english'
          #   break
          # end
        end
        if results.present?
          max_id = results.last.id - 1
          LoggerService.log("got #{results.size} tweets with ids #{results.first.try(:id)} down to #{results.last.try(:id)}")
        else
        end
      rescue Twitter::Error::TooManyRequests => e
        # NOTE: Your process could go to sleep for up to 15 minutes but if you
        # retry any sooner, it will almost certainly fail with the same exception.
        LoggerService.log("hit rate limit, suspending for 15 minutes: #{e.inspect}")
        sleep e.rate_limit.reset_in + 1
        retry
      rescue Twitter::Error::NotFound => e
        LoggerService.log("page not found, so we are probably done with this user: #{e.inspect}")
        return
      end
    end
    LoggerService.log("finished fetching tweets of #{user.id} (#{user.try(:screen_name)})")
  end

  protected

  def rest_client
    @rest_client ||= Twitter::REST::Client.new do |config|
      @secrets.each { |k, v| config.send("#{k}=", v) }
    end
  end

  def streaming_client
    @streaming_client ||= Twitter::Streaming::Client.new do |config|
      @secrets.each { |k, v| config.send("#{k}=", v) }
    end
  end
end
