class CreateImdbUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :imdb_users do |t|
      t.integer :i_id, index: true
      t.string :display_name, index: true
      t.string :username, index: true
      t.timestamps
    end
  end
end
