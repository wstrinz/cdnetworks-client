require 'webmock/rspec'

require File.expand_path('../../lib/cdnetworks-client.rb', __FILE__)

module ApiStubs
  def stub_auth_calls
    fake_token = "12345sessiontoken"
    fake_api_key = "anapikey56789"
    stub_login(fake_token)
    stub_get_api_keys(fake_token, fake_api_key)

    [fake_token, fake_api_key]
  end

  def stub_login(return_token)
    stub_request(:post, "#{@url}/api/rest/login").
      to_return body: JSON.pretty_unparse(loginResponse: {resultCode: 0,
                                                          session: [return_token, "svcGroup", "svcGroupIdentifier"]})
  end

  def stub_get_api_keys(session_token, return_key)
    stub_request(:get, "#{@url}/api/rest/getApiKeyList?output=json&session_token=#{session_token}").
    to_return body: JSON.pretty_unparse(apiKeyListResponse: {apiKeyInformation:
                                                             [1, 'serviceName', return_key, 'parentKey'],
                                                             resultCode: 0})
  end

  def stub_get_edge_traffic(expected_bandwidth)
    # TODO - take date as input and strftime it in output
    stub_request(:post, "https://openapi.us.cdnetworks.com/rest/traffic/edge").
      to_return body: JSON.pretty_unparse(edgeTrafficResponse: {returnCode: 0,
                                                                trafficItem:
                                                                ['200809162305', expected_bandwidth, 10.10]})
  end
end

RSpec.configure do |config|
  config.include ApiStubs
end
