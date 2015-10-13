require_relative 'spec_helper'

describe CdnetworksClient do
  before(:all) do
    @user = ENV['CDN_USER']
    @pass = ENV['CDN_PASS']

    unless @user && @pass
      skip "either CDN_USER or CDN_PASS env var not set. exiting"
    end

    WebMock.allow_net_connect!

    @client = CdnetworksClient.new(user: @user, pass: @pass, location: "Beta")
  end

  after(:all) do
    WebMock.disable_net_connect!
  end

  it 'gets a session' do
    expect(@client.get_session.first['sessionToken']).not_to be_nil
  end

  skip 'gets bandwidth usage' do
    usage = @client.bandwidth_usage("service_name", Date.today - 2, Date.today - 1)
    expect(usage).to eq(0)
  end
end
