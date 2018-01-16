# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180114131929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "imdb_genres", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imdb_title_genres", force: :cascade do |t|
    t.bigint "imdb_title_id"
    t.bigint "imdb_genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imdb_genre_id"], name: "index_imdb_title_genres_on_imdb_genre_id"
    t.index ["imdb_title_id"], name: "index_imdb_title_genres_on_imdb_title_id"
  end

  create_table "imdb_titles", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imdb_users", force: :cascade do |t|
    t.integer "i_id"
    t.string "display_name"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_name"], name: "index_imdb_users_on_display_name"
    t.index ["i_id"], name: "index_imdb_users_on_i_id"
    t.index ["username"], name: "index_imdb_users_on_username"
  end

  create_table "movietweetings_movies", id: :bigint, default: nil, force: :cascade do |t|
    t.string "title"
    t.string "genres"
    t.index ["id"], name: "index_movietweetings_movies_on_id"
  end

  create_table "movietweetings_ratings", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "movietweetings_user_id"
    t.bigint "movietweetings_movie_id"
    t.integer "rating"
    t.integer "rating_timestamp"
    t.index ["id"], name: "index_movietweetings_ratings_on_id"
    t.index ["movietweetings_movie_id"], name: "index_movietweetings_ratings_on_movietweetings_movie_id"
    t.index ["movietweetings_user_id"], name: "index_movietweetings_ratings_on_movietweetings_user_id"
    t.index ["rating"], name: "index_movietweetings_ratings_on_rating"
  end

  create_table "movietweetings_users", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "twitter_id"
    t.index ["id"], name: "index_movietweetings_users_on_id"
    t.index ["twitter_id"], name: "index_movietweetings_users_on_twitter_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "twitter_tweet_id"
    t.bigint "twitter_user_id"
    t.bigint "imdb_title_id"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imdb_title_id"], name: "index_ratings_on_imdb_title_id"
    t.index ["rating"], name: "index_ratings_on_rating"
    t.index ["twitter_tweet_id"], name: "index_ratings_on_twitter_tweet_id", unique: true
    t.index ["twitter_user_id"], name: "index_ratings_on_twitter_user_id"
  end

  create_table "twitter_tweets", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "t_id"
    t.bigint "twitter_user_id"
    t.text "text"
    t.string "source"
    t.datetime "t_created_at"
    t.boolean "truncated"
    t.bigint "in_reply_to_status_id"
    t.bigint "in_reply_to_user_id"
    t.string "in_reply_to_screen_name"
    t.string "geo"
    t.string "coordinates"
    t.string "place"
    t.string "contributors"
    t.boolean "is_quote_status"
    t.bigint "quote_count"
    t.bigint "reply_count"
    t.bigint "retweet_count"
    t.bigint "favorite_count"
    t.text "entities_urls"
    t.text "entities_hashtags"
    t.boolean "favorited"
    t.boolean "retweeted"
    t.boolean "possibly_sensitive"
    t.string "filter_level"
    t.string "lang"
    t.bigint "timestamp_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "imdb_title_id"
    t.index ["id"], name: "index_twitter_tweets_on_id"
    t.index ["t_id"], name: "index_twitter_tweets_on_t_id"
    t.index ["text"], name: "index_twitter_tweets_on_text"
    t.index ["twitter_user_id"], name: "index_twitter_tweets_on_twitter_user_id"
  end

  create_table "twitter_users", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "t_id"
    t.string "name"
    t.string "screen_name"
    t.string "location"
    t.string "url"
    t.text "description"
    t.string "translator_type"
    t.boolean "protected"
    t.boolean "verified"
    t.bigint "followers_count"
    t.bigint "friends_count"
    t.bigint "listed_count"
    t.bigint "favourites_count"
    t.bigint "statuses_count"
    t.string "utc_offset"
    t.string "time_zone"
    t.boolean "geo_enabled"
    t.string "lang"
    t.boolean "contributors_enabled"
    t.boolean "is_translator"
    t.string "profile_background_color"
    t.string "profile_background_image_url"
    t.string "profile_background_image_url_https"
    t.boolean "profile_background_tile"
    t.string "profile_link_color"
    t.string "profile_sidebar_border_color"
    t.string "profile_sidebar_fill_color"
    t.string "profile_text_color"
    t.boolean "profile_use_background_image"
    t.string "profile_image_url"
    t.string "profile_image_url_https"
    t.string "profile_banner_url"
    t.boolean "default_profile"
    t.boolean "default_profile_image"
    t.boolean "following"
    t.boolean "follow_request_sent"
    t.string "notifications"
    t.datetime "t_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_imdb_ratings", default: false
    t.boolean "fetched_tweets", default: false
    t.integer "twitter_tweets_count"
    t.integer "ratings_count"
    t.index ["id"], name: "index_twitter_users_on_id"
    t.index ["screen_name"], name: "index_twitter_users_on_screen_name"
    t.index ["t_id"], name: "index_twitter_users_on_t_id"
  end

end
