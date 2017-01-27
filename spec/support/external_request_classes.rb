RSpec.configure do |config|
  config.before(:each) do |example|
    allow(SlackBot).to receive(:post_message).and_return({}) unless example.metadata[:slack_bot]
    allow(RidersBlog).to receive(:retrieve_articles).and_return([]) unless example.metadata[:riders_blog]
    allow(FacebookApi).to receive(:events).and_return({}) unless example.metadata[:facebook_api]
  end
end
