class BlogRss

  def articles
    if @last_retrieved < Time.now - 15.minutes
      @articles = get_articles
    else
      @articles ||= get_articles
    end
  end

  def initialize(*args)
    options = args.extract_options!
    @url = options[:url]
    super()
    @articles = get_articles
  end

  protected
    def get_articles
      binding.pry
      uri = URI(@url)
      begin
        rss = Net::HTTP.get(uri)
        rss = Hash.from_xml(rss)['rss']['channel']['item']
      rescue SocketError => e
        flash[:error] = e
        rss = []
      end
      @last_retrieved = Time.now
      rss
    end
end