require 'webmock/rspec'

require File.expand_path('../../lib/cdnetworks-client.rb', __FILE__)

module ApiStubs
  def stub_auth_calls
    fake_token = "12345thetoken"
    fake_api_key = "EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    fake_identifier = "90525E70B7842930586545C6F1C9310C"
    fake_service_name = 'cdn.example-app.host.com'
    stub_login(fake_token, fake_identifier)
    stub_get_api_keys(fake_token, fake_service_name, fake_api_key)

    [fake_token, fake_api_key, fake_identifier, fake_service_name]
  end

  def stub_login(return_token, svc_identifier)
    resp = JSON.pretty_unparse({loginResponse: {returnCode: 0,
                                                session: [{sessionToken: return_token,
                                                           svcGroupName: "Service Group Name",
                                                           svcGroupIdentifier: svc_identifier}]}})

    stub_request(:post, "#{@url}/api/rest/login").to_return(body: resp)
  end

  def stub_failed_login
    stub_request(:post, "#{@url}/api/rest/login").to_return(body: JSON.pretty_unparse(loginResponse: {returnCode: 101}))
  end

  def stub_get_api_keys(session_token, service_name, return_key)
    resp = JSON.pretty_unparse({apiKeyInfo: {returnCode: 0,
                                             apiKeyInfoItem: [{type: 0,
                                                               serviceName: "Content Acceleration",
                                                               apiKey: "SERVICECATEGORY_CA",
                                                               parentApiKey: "SERVICECATEGORY_CA"},
                                                               {type: 1,
                                                                serviceName: service_name,
                                                                apiKey: return_key,
                                                                parentApiKey: "SERVICECATEGORY_CA"},
                                                                {type: 1,
                                                                 serviceName: "cdn.another.app.com",
                                                                 apiKey: "55555555555555555555555555555555",
                                                                 parentApiKey: "SERVICECATEGORY_CA"}]}})

    stub_request(:post, "#{@url}/api/rest/getApiKeyList").with(body: {"output"=>"json", "sessionToken"=>session_token}).to_return(body: resp)
  end

  def stub_get_edge_traffic(expected_bandwidth)
    # TODO - take date as input and strftime it in output
    resp = JSON.pretty_unparse(trafficResponse: {returnCode: 0,
                                                 trafficItem:
                                                 [{dateTime: '200809162305', bandwidth: 10, dataTransferred: expected_bandwidth}]})
    stub_request(:post, "#{@url}/api/rest/traffic/edge").to_return(body: resp)
  end

  def stub_pad_list(expected_service)
     resp = { "PadConfigResponse" => {
                "resultCode" => 200,
                "data"=> {
                  "errors" => "",
                  "data" => [ {"origin"=>expected_service, "pad"=>"pad.#{expected_service}", "id"=>11111},
                              {"origin"=>"another-site.com", "pad"=>"assets.another-site.com", "id"=>22222},
                              {"origin"=>"some.site.with.many.subdomains.com", "pad"=>"assets.many.subdomains.com", "id"=>33333},
                              {"origin"=>"somesite.s3.amazonaws.com", "pad"=>"assets.somesite.com", "id"=>44444} ]}}}

    stub_request(:post, "#{@url}/api/rest/pan/site/list").to_return(body: JSON.pretty_unparse(resp))
  end
end

RSpec.configure do |config|
  config.include ApiStubs
end
