class StatisticsService
  def user_stats
    TwitterUser.relevant.with_ratings_ratio
  end

  def ratings_thresholds(ratings_counts: [20, 40, 60, 80, 100], ratings_ratios: [0.2, 0.4, 0.6, 0.8])
    ratings_counts.map { |i| [i] * ratings_ratios.count }.inject([], &:+)
      .zip(ratings_ratios.reverse * ratings_counts.count)
      .map { |tweets, ratio| [tweets, ratio, TwitterUser.relevant.where("ratings_count >= ? AND #{TwitterUser::RATINGS_RATIO_SQL} <= ?", tweets, ratio).count] }
      .map { |tweets, ratio, count| [tweets, ratio, count, count / TwitterUser.relevant.count.to_f] }
  end

  def export
    export_user_stats
  end

  def export_user_stats
    data = user_stats
    FileUtils.mkdir_p 'export'
    File.open('export/user_stats.dat', 'w') { |f| data.each { |u| f.puts [u.id, u.twitter_tweets_count, u.ratings_count, u.ratings_ratio].join(',') } }

    export_desc_stats('user_desc_stats_ratings_ratio', data.map(&:ratings_ratio))
    export_desc_stats('user_desc_stats_twitter_tweets_count', data.map(&:twitter_tweets_count))
    export_desc_stats('user_desc_stats_ratings_count', data.map(&:ratings_count))


    File.open('export/user_ratings_thresholds.dat', 'w') { |f| ratings_thresholds.each { |t| f.puts t.join(',') } }
  end

  def export_desc_stats(file_name, data)
    File.write("export/#{file_name}.json", JSON.pretty_generate(data.descriptive_statistics))
  end
end
