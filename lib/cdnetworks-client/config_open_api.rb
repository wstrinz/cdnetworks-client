module ConfigOpenApi
  def list(options={})
    if location == "Beta"
      session_token = get_session_token
      keys = get_api_key_list(session_token)
      api_key = keys.find{|k| k["type"] == 0}["apiKey"]
      params = { sessionToken: session_token, apiKey: api_key }
      pad_path = "/api/rest/pan/site/list"
      response = call(pad_path, params.merge(options))
      if response[:code].to_s == "200"
        data = JSON.parse(response[:body])
        result_code = data.fetch("PadConfigResponse",{})["resultCode"]

        if OpenApiError::ERROR_CODES.keys.include?(result_code.to_s)
          OpenApiError::handle_error_response(response[:code], response[:body])
        else
          data["PadConfigResponse"]["data"]["data"]
        end
      end
    else
      call(config_open_path("list"),add_config_credentials(options))
    end
  end

  def view(options={})
    call(config_open_path("view"),add_config_credentials(options))
  end

  def add(options={})
    call(config_open_path("add"),add_config_credentials(options))
  end

  def edit(options={})
    call(config_open_path("edit"),add_config_credentials(options))
  end

  def config_open_path(command)
    "/config/rest/pan/site/#{command}"
  end

  def add_config_credentials(options)
    options[:user]     = @user
    options[:pass] = @password

    options
  end
end
