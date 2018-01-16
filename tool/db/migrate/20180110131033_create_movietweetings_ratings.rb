class CreateMovietweetingsRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :movietweetings_ratings, id: false do |t|
      t.bigint :id, primary_key: true, index: true
      t.bigint :movietweetings_user_id, index: true
      t.bigint :movietweetings_movie_id, index: true
      t.integer :rating, index: true
      t.integer :rating_timestamp
    end
  end
end
