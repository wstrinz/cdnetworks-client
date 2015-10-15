require "json"

require_relative "patches"

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
  attr_accessor :user, :password, :location

  MAX_SESSION_RETRIES = 2

  def initialize(credentials={})
    self.user       = credentials[:user]
    self.password   = credentials[:pass]
    self.location   = credentials[:location]
  end

  def compose_request(path,options)
    request = Net::HTTP::Post.new("#{base_url(location)}#{path}")
    request.set_form_data(options)
    request
  end

  def call(path,options,session_retries=0)
    response = http.request(compose_request(path,options))

    if location == "Beta"
      process_beta_response(path, options, response, session_retries)
    else
      response_hash = { code: response.code, body: response.body }
    end
  end

  private

  def base_url(loc=nil)
    case
    when loc == "Korea"
      "https://openapi.kr.cdnetworks.com"
    when loc == "Japan"
      "https://openapi.jp.cdnetworks.com"
    when loc == "China"
      "https://openapi.txnetworks.cn"
    when loc == "Beta"
      "https://openapi-beta.cdnetworks.com"
    else
      "https://openapi.us.cdnetworks.com"
    end
  end

  def process_beta_response(path, options, response, session_retries)
    if expired_session_response?(response)
      if session_retries <= MAX_SESSION_RETRIES
        new_session_token = get_session_token(true)
        options[:sessionToken] = new_session_token
        return call(path, options, session_retries + 1)
      else
        raise OpenApiError::CriticalApiError.new("Session expired and failed to be re-established after #{session_retries} tries")
      end
    end

    begin
      data = JSON.parse(response.body)

      result_code = data.values.first['resultCode'] || data.values.first['returnCode']

      if !%w{0 200 404}.include?(result_code.to_s)
        OpenApiError::ErrorHandler.handle_error_response(result_code, response.body)
      else
        {code: result_code, body: data}
      end
    rescue JSON::ParserError
      raise OpenApiError::CriticalApiError.new("Unparseable body: #{response.body}")
    end
  end

  def http
    uri = URI.parse(base_url(location))

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http
  end

  def expired_session_response?(response)
    if response.code.to_s == "200"
      begin
        parsed = JSON.parse(response.body.to_s)
        if parsed.values.first
          parsed.values.first['returnCode'] == 102 ||
            parsed.values.first['resultCode'] == 102
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
