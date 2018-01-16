class UpdateBigInts < ActiveRecord::Migration[5.1]
  def change
    change_column :imdb_titles, :id, :bigint
    remove_column :imdb_titles, :i_id
  end
end
