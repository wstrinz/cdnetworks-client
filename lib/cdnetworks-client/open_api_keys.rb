module OpenApiKeys
  BASE_URL = "https://openapi.us.cdnetworks.com"
  GET_KEY_URL = "#{BASE_URL}/api/rest/getApiKeyList"

  def get_api_key(session_token)
    params = {
      session_token: session_token,
      output: "json"
    }
    uri = URI(GET_KEY_URL)
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri) do |response|
      if response.code == "200"
        body = response.read_body
        parsed = JSON.parse(body)
        return_code = parsed['apiKeyListResponse']['resultCode']

        unless %w{0 200}.include? return_code.to_s
          OpenApiError::ErrorHandler.handle_error_response(return_code, body)
        end

        return parsed['apiKeyListResponse']['apiKeyInformation'][2]
      else
        OpenApiError::ErrorHandler.handle_error_response(response.code, body)
      end
    end
  end
end
