require 'csv'

class MovietweetingsService
  PATH = Rails.root.join('movietweetings')

  def import_data

  end

  def import_movies
    existing = MovietweetingsMovie.ids
    items = []
    CSV.foreach(PATH.join('movies.dat'), col_sep: '::') do |row|
      next if existing.include?(row[0])
      items << {
        id: row[0],
        title: row[1],
        genres: row[2]
      }
    end
    MovietweetingsMovie.import(items)
  end

  def import_users
    existing = MovietweetingsUser.ids.to_a
    items = []
    CSV.foreach(PATH.join('users.dat'), col_sep: '::') do |row|
      # next if existing.include?(row[0])
      items << {
        id: row[0],
        twitter_id: row[1]
      }
    end
    MovietweetingsUser.import(items, validate: false)
  end

  def import_ratings
    existing = MovietweetingsRating.ids
    items = []
    CSV.foreach(PATH.join('ratings.dat'), col_sep: '::') do |row|
      next if existing.include?(row[0])
      items << {
        movietweetings_user_id: row[0],
        movietweetings_movie_id: row[1],
        rating: row[2],
        rating_timestamp: row[3]
      }
    end
    MovietweetingsRating.import(items)
  end
end
