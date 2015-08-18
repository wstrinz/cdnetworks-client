module StatisticsOpenApi
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

  def bandwidth_usage
    opts = {
      sessionToken: "",
      apiKey: "",
      fromDate: "",
      toDate: "",
      timeInterval: "",
      output: "json"
    }

    response = call(BANDWIDTH_PATH, opts)

    StatsHelper.handle_response(response)

    # response = @@bandwidth_use.lookup(
    #   site_id,
    #   @@sp.username,
    #   @@sp.plaintext_password,
    #   "1", # CL - Using 1 gives us stuff we want. using 2 gives us something else. What either means is beyond me.
    #   start_time.strftime("%Y-%m-%d %H:%M:%S"),
    #   end_time.strftime("%Y-%m-%d %H:%M:%S")# CL - These dates have to be in this exact format
    # )

    # # CL - If there is an error code, find out what it means
    # raise error_to_string(response) if response.to_f < 0

    # return response.to_f
  end
end
