# Module to interact with Facebook's Graph API
module FacebookApi

  # Returns *Array*. Events from the Riders Page.
  def self.events
    if !@updated_at || @updated_at < Time.now - 15.minutes
      @events = get_events
      if @events['error']
        @auth_token = refresh_auth_token
        @events = get_events
      else
        @updated_at = Time.now
      end
    end
    @events ||= get_events
  end

  # Sets and stores auth_token from API
  def self.auth_token
    @auth_token ||= get_auth_token
  end

  # Sets auth_token
  def self.refresh_auth_token
    @auth_token = get_auth_token
  end

  protected

  # Retrieves auth_token from API
  def self.get_auth_token
    uri = URI("https://graph.facebook.com/oauth/access_token?client_id=560921750673121&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials")
    Net::HTTP.get(uri)
  rescue => e
    Rails.logger.warn 'FacebookApi Error:'
    Rails.logger.warn e
  end

  # Retrieves events from API
  def self.get_events
    response = {}
    begin
      if auth_token
        uri = URI("https://graph.facebook.com/MidnightRiders/events?#{URI.encode_www_form_component(auth_token)}")
        response = Net::HTTP.get(uri)
        response = JSON.parse(response)
      end
    rescue => e
      Rails.logger.error 'FacebookApi Error:'
      Rails.logger.error e
    end
    response
  end
end
