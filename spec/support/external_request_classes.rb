RSpec.configure do |config|
  config.before(:each) do
    allow(SlackBot).to receive(:post_message).and_return({})
    allow(RidersBlog).to receive(:retrieve_articles).and_return([])
  end
end
