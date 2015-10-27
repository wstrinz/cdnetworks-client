module ConfigOpenApi
  def list(options={})
    response = call(config_open_path("list"), add_config_credentials(options))
    if location == "Beta"
      response[:body]["PadConfigResponse"]["data"]["data"]
    else
      response
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
    if location == "Beta"
      "/api/rest/pan/site/#{command}"
    else
      "/config/rest/pan/site/#{command}"
    end
  end

  def add_config_credentials(options)
    if location == "Beta"
      session_token = get_session_token
      keys = get_api_key_list(session_token)
      api_key = keys.find{|k| k["type"] == 0}["apiKey"]

      options[:sessionToken] = session_token
      options[:apiKey] = api_key
    else
      options[:user]     = @user
      options[:pass] = @password
    end

    options
  end
end
