require 'webmock/rspec'

require File.expand_path('../../lib/cdnetworks-client.rb', __FILE__)

module ApiStubs
  def stub_auth_calls
    fake_token = "12345sessiontoken"
    fake_api_key = "EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    fake_identifier = "90525E70B7842930586545C6F1C9310C"
    stub_login(fake_token, fake_identifier)
    stub_get_api_keys(fake_token, fake_api_key)

    [fake_token, fake_api_key, fake_identifier]
  end

  def stub_login(return_token, svc_identifier)
    resp = JSON.pretty_unparse({loginResponse: {resultCode: 0,
                                                session: [{sessionToken: return_token,
                                                           svcGroupName: "Service Group Name",
                                                           svcGroupIdentifier: svc_identifier}]}})

    stub_request(:post, "#{@url}/api/rest/login").to_return(body: resp)
  end

  def stub_get_api_keys(session_token, return_key)
    resp = JSON.pretty_unparse({apiKeyInfo: {returnCode: 0,
                                             apiKeyInfoItem: [{type: 0,
                                                               serviceName: "Content Acceleration",
                                                               apiKey: "SERVICECATEGORY_CA",
                                                               parentApiKey: "SERVICECATEGORY_CA"},
                                                               {type: 1,
                                                                serviceName: "cdn.example-app.1234.host.com",
                                                                apiKey: return_key,
                                                                parentApiKey: "SERVICECATEGORY_CA"},
                                                                {type: 1,
                                                                 serviceName: "cdn.another.app.com",
                                                                 apiKey: "55555555555555555555555555555555",
                                                                 parentApiKey: "SERVICECATEGORY_CA"}]}})

    stub_request(:get, "#{@url}/api/rest/getApiKeyList?output=json&session_token=#{session_token}").to_return(body: resp)
  end

  def stub_get_edge_traffic(expected_bandwidth)
    # TODO - take date as input and strftime it in output
    resp = JSON.pretty_unparse(trafficResponse: {returnCode: 0,
                                                 trafficItem:
                                                 ['200809162305', expected_bandwidth, 10.10]})
    stub_request(:post, "https://openapi.us.cdnetworks.com/rest/traffic/edge").to_return(body: resp)
  end
end

RSpec.configure do |config|
  config.include ApiStubs
end
