require 'csv'

class ImdbService

  def initialize
  end

  def scrape!
    begin
      scrape_missing_titles!
      scrape_incomplete_titles!
    rescue
      sleep 1.minute
      retry
    end
  end

  def scrape_missing_titles!
    LoggerService.log("preparing to scrape missing imdb titles")
    missing_ids = (Rating.select(:imdb_title_id).where.not(imdb_title_id: nil).distinct.map(&:imdb_title_id) - ImdbTitle.ids)
    scrape_titles!(missing_ids)
  end

  def scrape_incomplete_titles!
    LoggerService.log("preparing to scrape incomplete imdb titles")
    incomplete_ids = (ImdbTitle.ids - ImdbTitleGenre.select(:imdb_title_id).distinct.map(&:imdb_title_id))
    scrape_titles!(incomplete_ids, check_for_existing: true, batch_size: 1)
  end

  def scrape_titles!(ids, save_new: false, check_for_existing: false, check_genres: false, batch_size: 20)
    LoggerService.log("starting the scraping of #{ids.count} imdb titles")
    genre_index = ImdbGenre.all.index_by(&:slug)
    batch_count = 1
    while ids.present?
      batch = ids.shift(batch_size)
      LoggerService.log("started scraping batch #{batch_count} of #{batch_size} imdb titles: #{batch.to_sentence}")
      scraped_titles = batch.map do |id|
        scrape_title(id, genre_index: genre_index, save_new: save_new, check_for_existing: check_for_existing, check_genres: check_genres)
      end.compact
      ImdbTitle.import(scraped_titles, recursive: true)
      LoggerService.log("scraped batch #{batch_count}, #{ids.size} titles (#{ids.size / batch_size} batches) remaining")
      batch_count += 1
    end
  end

  def scrape_title(title, genre_index: nil, save_new: false, check_for_existing: false, check_genres: false)
    # genres index should be computed outside this function is scraping multiple
    # titles iteratively
    genre_index ||= ImdbGenre.all.index_by(&:slug)
    genres = []
    if title.is_a?(Numeric)
      title = check_for_existing ? ImdbTitle.find_or_initialize_by(id: title) : ImdbTitle.new(id: title)
    end

    uri = URI(title.requestable_url)
    response = nil
    redirects = 0
    while (response.blank? || response.code.to_i == 301) && redirects < 3
      request = Net::HTTP::Get.new(uri)
      response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
      if response.code.to_i == 301
        uri = URI("http://www.imdb.com#{response['Location']}")
        redirects += 1
      end
    end
    html = Nokogiri::HTML(response.body)

    # find and update genres
    html.css('div[itemprop=\'genre\'] a').map do |link|
      attrs = {
        name: link.text.strip,
        url: link.attr('href')
      }

      genre = genre_index[ImdbGenre.name_to_slug(attrs[:name])]
      if check_genres
        genre ||= Genre.new
        genre.assign_attributes(attrs)
        genre.save!
      end

      genres << genre
    end

    # update title attributes
    title.title ||= html.css('h1[itemprop=\'name\']').text.strip
    title_chars = title.title.chars
    title_chars.pop while title_chars.last == ' ' # special character, not a space
    title_chars.shift while title_chars.first == ' ' # special character, not a space
    title.title = title_chars.join
    title.year ||= html.css('h1[itemprop=\'name\'] #titleYear a').first.try(:text).try(:to_i)
    title.url = title.url_from_id
    title.url = uri.to_s if redirects > 0
    title.imdb_genres = genres

    return title if title.new_record? && !save_new

    title.save!
    nil
  end

  def import_users
    files = Dir.glob(Rails.root.join('imdb_scraping', 'scraped_data', '*'))
    users = []
    existing_ids = ImdbUser.pluck(:id)
    files.each do |file|
      CSV.foreach(file) do |row|
        id = row.pop.match(/\/user\/ur([0-9]*)\//)[1].to_i
        display_name = row.join('')
        username = (display_name.include?(' ') ? nil : display_name)
        unless existing_ids.include?(id)
          users << {
            id: id,
            i_id: id,
            display_name: display_name,
            username: username
          }
          existing_ids << id
        end
      end
    end
    ImdbUser.import(users)
  end
end
