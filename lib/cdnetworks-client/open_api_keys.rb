module OpenApiKeys
  GET_KEY_PATH = "/api/rest/getApiKeyList"

  def get_api_key_list(session_token)
    params = {
      output: "json",
      sessionToken: session_token
    }
    uri = URI("#{base_url(@location)}/#{GET_KEY_PATH}")
    uri.query = URI.encode_www_form(params)

    response_handler = lambda do |response|
      if response[:code] == "200"
        body = response[:body]
        parsed = JSON.parse(body)
        return_code = parsed['apiKeyInfo']['returnCode']

        unless %w{0 200}.include? return_code.to_s
          OpenApiError::ErrorHandler.handle_error_response(return_code, body)
        end

        parsed['apiKeyInfo']['apiKeyInfoItem']
      else
        OpenApiError::ErrorHandler.handle_error_response(response[:code], body)
      end
    end

    response = call(GET_KEY_PATH, params)
    return response_handler.call(response)
  end

  def get_api_key(session_token, service_name)

    key_for_service = (get_api_key_list(session_token) || []).find do |service|
      service['serviceName'] == service_name
    end

    unless key_for_service
      raise "No key found for #{service_name}"
    end

    return key_for_service['apiKey']
  end
end
