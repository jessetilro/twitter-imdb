class ImdbTitleGenre < ApplicationRecord
  belongs_to :imdb_title
  belongs_to :imdb_genre

  validates :imdb_title_id, uniqueness: { scope: :imdb_genre_id }

  def self.import_from_movietweetings!
    genres = ImdbGenre.all.index_by(&:slug)
    title_genres = []
    MovietweetingsMovie.all.each do |movie|
      gs = movie.genres.to_s.split('|')
      gs.each do |g|
        slug = ImdbGenre.name_to_slug(g)
        genres[slug] = ImdbGenre.create!(name: g, slug: slug) unless genres.key?(slug)
        title_genres << {
          imdb_title_id: movie.id,
          imdb_genre_id: genres[slug].id
        }
      end
    end
    ImdbTitleGenre.import(title_genres)
  end
end
