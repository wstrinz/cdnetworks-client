module OpenApiKeys
  GET_KEY_PATH = "/api/rest/getApiKeyList"

  def get_api_key_list(session_token)
    params = {
      output: "json",
      sessionToken: session_token
    }
    uri = URI("#{base_url(@location)}/#{GET_KEY_PATH}")
    uri.query = URI.encode_www_form(params)

    response = call(GET_KEY_PATH, params)

    response[:body]['apiKeyInfo']['apiKeyInfoItem']
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
