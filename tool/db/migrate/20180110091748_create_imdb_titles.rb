class CreateImdbTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :imdb_titles do |t|
      t.integer :i_id, index: true
      t.string :title
      t.string :url
      t.integer :year
      t.timestamps
    end
  end
end
