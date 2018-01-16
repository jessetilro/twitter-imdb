class CreateMovietweetingsMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movietweetings_movies, id: false do |t|
      t.bigint :id, primary_key: true, index: true
      t.string :title
      t.string :genres
    end
  end
end
