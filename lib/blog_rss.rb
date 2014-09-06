# Basic module to get blog articles from RSS URLs
class BlogRss

  # Returns *Array* of articles.
  # +@last_retrieved+ is used to make sure articles are only requested
  # every 15 minutes at most.
  def self.articles
    if @last_retrieved && @last_retrieved < Time.now - 15.minutes
      @articles = get_articles
    else
      @articles ||= get_articles
    end
  end

  # No URL for the base module.
  def self.url
    raise('No URL has been assigned. This is the Generic Blog class!')
  end

  protected

    # Retrieves articles from url.
    def self.get_articles
      uri = URI(url)
      begin
        rss = Net::HTTP.get(uri)
        rss_parsed = Hash.from_xml(rss)
        rss = rss_parsed['rss']['channel']['item'] if rss_parsed
      rescue => e
        Rails.logger.info 'Blog error for ' + self.url
        Rails.logger.info e
        Rails.logger.info rss
      end
      rss ||= []
      @last_retrieved = Time.now
      if rss.empty?
        @articles || []
      else
        rss
      end
    end
end