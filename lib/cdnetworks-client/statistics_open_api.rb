module StatisticsOpenApi
  include AuthSession
  include OpenApiKeys

  BANDWIDTH_PATH = "api/rest/traffic/edge"

  class StatsHelper
    def self.handle_response(resp)
      if resp[:code] == "200"
        JSON.parse(resp[:body])['bandwidth']
      else
        if desc = OpenApiError::ERROR_CODES[resp[:code]]
          raise "Error #{resp[:code]}: #{desc}"
        else
          raise "Unexpected response #{resp[:code]}"
        end
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
