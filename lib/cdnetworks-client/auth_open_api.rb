module AuthOpenApi
  LOGIN_URL = "/api/rest/login"
  LOGOUT_URL = "/api/rest/logout"

  class AuthSession
    def raise_handled_error(code, desc)
      raise OpenApiError::ApiError.new("Auth error: #{code} - #{desc}")
    end

    def initialize(user, pass, base_url)
      @base_url = base_url
      @user = user
      @pass = pass
    end

    def session
      @session ||= login
    end

    def login
      params = {
        user: @user,
        pass: @pass,
        output: "json"
      }
      uri = URI("#{@base_url}#{LOGIN_URL}")

      response = Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https') do |http|

        request = Net::HTTP::Post.new uri.to_s
        request.set_form_data(params)

        http.request request # Net::HTTPResponse object
      end

      if error = OpenApiError::ERROR_CODES[response.code.to_s]
        raise_handled_error(response.code, error)
      elsif %w{0 200}.include?(response.code.to_s)

        data = JSON.parse(response.body)
        code = data.fetch('loginResponse',{})['returnCode']

        if error = OpenApiError::ERROR_CODES[code.to_s]
          raise_handled_error(code, error)
        else
          data['loginResponse']['session']
        end
      else
        raise OpenApiError::ApiError.new("Unknown Auth response: #{response.code}\n#{response.body}")
      end
    end

    def logout
      params = {
        user: @user,
        pass: @pass,
        output: "json"
      }
      request = Net::HTTP::Post.new("#{@base_url}#{LOGIN_URL}")
      request.set_form_data(params)

      response = http.request(request)

      if error = OpenApiError::ERROR_CODES[response.code]
        raise_handled_error(response.code, error)
      elsif %w{0 200}.include?(response.code)
        data = JSON.parse(response.body)
        code = data.fetch('loginResponse',{})['returnCode']

        if error = OpenApiError::ERROR_CODES[code.to_s]
          raise_handled_error(code, error)
        else
          data['loginResponse']['session']
        end
      else
        raise OpenApiError::ApiError.new("Unknown Auth response: #{response.code}\n#{response.body}")
      end
    end

    def expired?
      raise "not implemented"
    end
  end

  def get_session(reset_session = false)
    if !@auth_session || reset_session
      @auth_session = AuthSession.new(@user, @password, base_url(@location))
    end

    session = Array.wrap(@auth_session.session)[keynum]

    if session.is_a?(Hash)
      session['sessionToken']
    else
      nil
    end
  end
end
