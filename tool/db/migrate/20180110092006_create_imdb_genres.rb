class CreateImdbGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :imdb_genres do |t|
      t.string :name
      t.string :slug
      t.string :url
      t.timestamps
    end
  end
end
