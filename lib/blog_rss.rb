# Basic module to get blog articles from RSS URLs
class BlogRss

  # Returns *Array* of articles.
  # +@last_retrieved+ is used to make sure articles are only requested
  # every 15 minutes at most.
  def self.articles
    if @last_retrieved && @last_retrieved < Time.current - 15.minutes
      @articles = retrieve_articles
    else
      @articles ||= retrieve_articles
    end
  end

  # No URL for the base module.
  def self.url
    raise('No URL has been assigned. This is the Generic Blog class!')
  end

  # Retrieves articles from url.
  def self.retrieve_articles
    rss = request_rss_items || []
    if rss.is_a?(Array) && rss.present?
      @last_retrieved = Time.current
      rss
    else
      @articles || []
    end
  end

  def self.request_rss_items
    uri = URI(url)
    rss = Net::HTTP.get(uri)
    rss_parsed = Hash.from_xml(rss)
    rss_parsed.dig('rss', 'channel', 'item')
  rescue => e
    Rails.logger.error 'Blog error for ' + url
    Rails.logger.error e
    Rails.logger.info 'RSS: ' + rss
  end
end
