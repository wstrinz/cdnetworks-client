module ConfigOpenApi

  def list(options={})
    call(config_open_path("list"),add_config_credentials(options))
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
    # options[:user]     = @user
    # options[:pass] = @password
    session = get_session(@user, @password)
    options[:sessionToken] = session.first
    options[:apiKey] = get_api_key(session.first)

    options
  end
end
