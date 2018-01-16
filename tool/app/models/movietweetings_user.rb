class MovietweetingsUser < ApplicationRecord
  belongs_to :twitter_user, foreign_key: :twitter_id
end
