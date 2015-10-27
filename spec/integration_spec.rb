require_relative 'spec_helper'

describe CdnetworksClient do
  before(:all) do
    @user = ENV['CDN_USER']
    @pass = ENV['CDN_PASS']

    unless @user && @pass
      skip "either CDN_USER or CDN_PASS env var not set. skipping"
    end

    WebMock.allow_net_connect!

    @client = CdnetworksClient.new(user: @user, pass: @pass, location: "Beta")
  end

  after(:all) do
    WebMock.disable_net_connect!
  end

  it 'gets a session' do
    expect(@client.get_session_token).not_to be_nil
  end

  it 'gets bandwidth usage' do
    pad = ENV['CDN_PAD']
    skip "must set CDN_PAD env var" unless pad
    usage = @client.bandwidth_usage(pad, Date.today - 2, Date.today - 1)
    expect(usage).to be > 0
  end

  it 'lists pads for a session' do
    pads = @client.list

    expect(pads.length).to be > 0
  end
end
