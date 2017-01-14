class SlackBot
  POST_MESSAGE_URI = URI.parse('https://slack.com/api/chat.postMessage')

  def self.post_message(text, channel = '#web')
    response = Net::HTTP.post_form(POST_MESSAGE_URI,
      token: ENV['PORTALBOT_KEY'],
      channel: channel,
      text: text,
      username: 'Portalbot',
      icon_url: 'http://www.midnightriders.com/images/logo-128.png')
    response = JSON.parse(response.body)
    raise("Unable to post \"#{text}\" to #{channel}: #{response}") unless response['ok']
  rescue => e
    Rails.logger.error e
  end
end
