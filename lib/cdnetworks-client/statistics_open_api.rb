module StatisticsOpenApi
  include AuthOpenApi
  include OpenApiKeys

  BANDWIDTH_PATH = "api/rest/traffic/edge"

  class StatsHelper
    def self.handle_error_response(code, body)
      raise "Error #{resp[:code]}: #{desc}"
    end

    def self.handle_response(resp)
      if resp[:code] == "200"
        parsed = JSON.parse(resp[:body])
        return_code = parsed['edgeTrafficResponse']['returnCode'].to_s

        unless %w{0 200}.include? return_code
          OpenApiError::ErrorHandler.handle_error_response(return_code, resp[:body])
        end

        parsed['edgeTrafficResponse']['trafficItem'][1]
      else
        OpenApiError::ErrorHandler.handle_error_response(resp[:code], resp[:body])
      end
    end
  end

  def bandwidth_usage(from, to, time_interval = 2)
    session = get_session(@user, @password)
    api_key = get_api_key(session.first)

    opts = {
      sessionToken: session.first, # == sessionToken. Should make this a has in auth module
      apiKey: api_key,
      fromDate: from,
      toDate: to,
      timeInterval: time_interval,
      output: "json"
    }

    response = call(BANDWIDTH_PATH, opts)

    StatsHelper.handle_response(response)
  end
end
