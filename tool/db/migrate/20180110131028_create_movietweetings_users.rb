class CreateMovietweetingsUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :movietweetings_users, id: false do |t|
      t.bigint :id, primary_key: true, index: true
      t.bigint :twitter_id, index: true
    end
  end
end
