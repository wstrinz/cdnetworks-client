require "json"

require "cdnetworks-client/version"
require "cdnetworks-client/cache_purge_api"
require "cdnetworks-client/config_open_api"
require "cdnetworks-client/cache_flush_open_api"
require "cdnetworks-client/open_api_error"
require "cdnetworks-client/auth_open_api"
require "cdnetworks-client/open_api_keys"
require "cdnetworks-client/statistics_open_api"

class CdnetworksClient
  include ConfigOpenApi
  include CachePurgeApi
  include CacheFlushOpenApi
  include StatisticsOpenApi


  def initialize(credentials={})
    @user       = credentials[:user]
    @password   = credentials[:pass]
    @location   = credentials[:location]
  end

  def compose_request(path,options)
    request = Net::HTTP::Post.new("#{base_url(@location)}#{path}")
    request.set_form_data(options)
    request
  end

  def call(path,options)
    begin
      response = http.request(compose_request(path,options))

      if expired_session_response?(response)
        new_session = get_session(true)
        options[:sessionToken] = new_session.first["sessionToken"]
        return call(path, options)
      end
      response_hash = { code: response.code, body: response.body }
    rescue StandardError=>e
      "An error has occurred connecting to the CDNetworks API (#{e})"
    end
  end

  private

  def base_url(location=nil)
    case
    when location == "Korea"
      "https://openapi.kr.cdnetworks.com"
    when location == "Japan"
      "https://openapi.jp.cdnetworks.com"
    when location == "China"
      "https://openapi.txnetworks.cn"
    when location == "Beta"
      "https://openapi-beta.cdnetworks.com"
    else
      "https://openapi.us.cdnetworks.com"
    end
  end

  def http
    uri = URI.parse(base_url(@location))

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http
  end

  def expired_session_response?(response)
    if response.code.to_s == "200"
      begin
        parsed = JSON.parse(response.body)
        if parsed.values.first
          parsed.values.first['returnCode'] == 102
        else
          false
        end
      rescue JSON::ParserError
        false
      end
    else
      false
    end
  end
end
