class RunnerService
  def self.run
    log("initiating process of collecting tweets")
    begin
      twitter_service = TwitterService.new
      # user whose tweets seem to have been fetched incorrectly
      if false
        log("fetching tweets of users whose set of fetched tweets seems incomplete")
        TwitterUser
          .where(id: TwitterUser.already_fetched.english.having_imdb_ratings.ids)
          .with_missing_tweets_count
          .select { |u| u.missing_tweets_count > 200 }
          .each do |u|
          max_id = u.twitter_tweets.minimum(:id) - 1
          twitter_service.fetch_user_tweets(u, max_id: max_id)
        end
      end
      # well known and selected users
      log("fetching tweets of well known and selected users whose tweets were not fetched yet")
      TwitterUser
        .having_imdb_ratings
        .not_yet_fetched
        .english
        .order(statuses_count: :asc).each do |u|
        twitter_service.fetch_user_tweets(u)
      end
      # remaining unknown users
      log("fetching tweets of remaining unknown users")
      MovietweetingsUser.where.not(twitter_id: TwitterUser.where(fetched_tweets: true).ids).each do |u|
        twitter_service.fetch_user_tweets(u.twitter_id)
      end
    rescue => e
      log("an error interrupted the process, retrying in 1 minute: #{e.inspect}")
      sleep(1.minute.to_i)
      retry
    end
  end

  def self.log(x)
    LoggerService.log(x)
  end
end
