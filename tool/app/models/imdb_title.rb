class ImdbTitle < ApplicationRecord
  has_many :imdb_title_genres, inverse_of: :imdb_title
  has_many :imdb_genres, through: :imdb_title_genres, inverse_of: :imdb_titles

  has_many :ratings

  before_save do
    year ||= ImdbTitle.year_from_title(title)
  end

  def requestable_url
    ImdbTitle.requestable_url_from_id(id)
  end

  def url_from_id
    ImdbTitle.url_from_id(id)
  end

  def self.import_from_movietweetings!
    existing = ImdbTitle.ids
    titles = []
    MovietweetingsMovie.all.each do |movie|
      next if existing.include?(movie.id)
      titles << {
        id: movie.id,
        title: movie.title,
        year: ImdbTitle.year_from_title(movie.title),
        url: ImdbTitle.url_from_id(movie.id)
      }
    end
    ImdbTitle.import(titles)
  end

  def self.year_from_title(title)
    match = /.*\(([0-9]{4})\)/.match(title)
    match[1] if match.present?
  end

  def self.url_from_id(id)
    identifier = id.to_s.rjust(7, '0')
    "http://www.imdb.com/title/tt#{identifier}"
  end

  def self.requestable_url_from_id(id)
    "#{url_from_id(id)}/"
  end

  def self.id_from_url(url)
    match = /http(?:s|):\/\/(?:www\.|)imdb.com\/title\/tt([0-9]*)/.match(url)
    match[1].to_i if match.present?
  end
end
