class BlogRss

  def self.articles
    if @last_retrieved && @last_retrieved < Time.now - 15.minutes
      @articles = get_articles
    else
      @articles ||= get_articles
    end
  end

  def self.url
    raise('No URL has been assigned. This is the Generic Blog class!')
  end

  protected
    def self.get_articles
      uri = URI(url)
      begin
        rss = Net::HTTP.get(uri)
        rss = Hash.from_xml(rss)['rss']['channel']['item']
      rescue SocketError => e
        puts 'RidersBlog error:'
        puts e
        rss = []
      end
      @last_retrieved = Time.now
      if rss.empty?
        @articles || []
      else
        rss
      end
    end
end