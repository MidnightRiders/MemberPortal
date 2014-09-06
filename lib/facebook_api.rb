# Module to interact with Facebook's Graph API
module FacebookApi

  # Returns *Array*. Events from the Riders Page.
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

  # Sets and stores auth_token from API
  def self.auth_token
    @auth_token ||= self.get_auth_token
  end

  # Sets auth_token
  def self.refresh_auth_token
    @auth_token = self.get_auth_token
  end

  protected

    # Retrieves auth_token from API
    def self.get_auth_token
      uri = URI('https://graph.facebook.com/oauth/access_token?client_id=560921750673121&client_secret=920dfdce9d33e5f0b2ff46d9a3ea343a&grant_type=client_credentials')
      Net::HTTP.get(uri)
    end

    # Retrieves events from API
    def self.get_events
      uri = URI("https://graph.facebook.com/MidnightRiders/events?#{URI.encode(self.auth_token)}")
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end
end