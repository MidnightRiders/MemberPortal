FactoryGirl.define do
  factory :api_v1_session, class: 'Api::V1::Session' do
    user ""
    token "MyString"
    expiration "2016-12-18 00:32:36"
  end
end
