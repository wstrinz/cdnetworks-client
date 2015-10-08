module OpenApiKeys
  BASE_URL = "https://openapi-beta.cdnetworks.com"
  GET_KEY_URL = "#{BASE_URL}/api/rest/getApiKeyList"

  def get_api_key(session_token, service_name)
    params = {
      sessionToken: session_token,
      output: "json"
    }
    uri = URI(GET_KEY_URL)
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri) do |response|
      if response.code == "200"
        body = response.read_body
        parsed = JSON.parse(body)
        return_code = parsed['apiKeyInfo']['returnCode']

        unless %w{0 200}.include? return_code.to_s
          OpenApiError::ErrorHandler.handle_error_response(return_code, body)
        end

        key_for_service = (parsed['apiKeyInfo']['apiKeyInfoItem'] || []).find do |service|
          service['serviceName'] == service_name
        end

        unless key_for_service
          raise "No key found for #{service_name}"
        end

        return key_for_service['apiKey']
      else
        OpenApiError::ErrorHandler.handle_error_response(response.code, body)
      end
    end
  end
end
