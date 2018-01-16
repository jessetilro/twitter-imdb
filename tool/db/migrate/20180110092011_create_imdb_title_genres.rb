class CreateImdbTitleGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :imdb_title_genres do |t|
      t.references :imdb_title
      t.references :imdb_genre
      t.timestamps
    end
  end
end
