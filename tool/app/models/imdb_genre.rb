class ImdbGenre < ApplicationRecord
  has_many :imdb_title_genres
  has_many :imdb_titles, through: :imdb_title_genres, inverse_of: :imdb_genres
  
  before_save do
    slug ||= ImdbGenre.name_to_slug(name)
  end

  def self.name_to_slug(name)
    name.to_s.chars.select { |l| /[[:alpha:]]/.match?(l) }.join.downcase
  end
end
