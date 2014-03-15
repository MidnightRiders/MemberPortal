class FacebookApi

  def self.events
    if !@updated_at || @updated_at < Time.now - 15.minutes
      @events = self.get_events
      if @events['error']
        @auth_token = self.refresh_auth_token
        @events = self.get_events
      else
        @updated_at = Time.now
      end
    end
    @events ||= self.get_events
  end

  def self.auth_token
    @auth_token ||= self.get_auth_token
  end
  def self.refresh_auth_token
    @auth_token = self.get_auth_token
  end

  protected

    def self.get_auth_token
      uri = URI('https://graph.facebook.com/oauth/access_token?client_id=560921750673121&client_secret=***REMOVED***&grant_type=client_credentials')
      begin
        token = Net::HTTP.get(uri)
      rescue SocketError => e
        flash[:error] = e
        token = false
      end
      token
    end

    def self.get_events
      uri = URI("https://graph.facebook.com/MidnightRiders/events?#{URI.encode(self.auth_token)}")
      begin
        response = Net::HTTP.get(uri)
      rescue SocketError => e
        flash[:error] = e
        []
      else
        JSON.parse(response)
      end
    end
end