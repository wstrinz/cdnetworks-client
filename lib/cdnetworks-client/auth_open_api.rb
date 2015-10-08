module AuthOpenApi
  LOGIN_URL = "/api/rest/login"
  LOGOUT_URL = "/api/rest/logout"

  class AuthSession
    def raise_handled_error(code, desc)
      raise "Auth error: #{code} - #{desc}"
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
      response = Net::HTTP.post_form(URI("#{@base_url}#{LOGIN_URL}"), params)

      if error = OpenApiError::ERROR_CODES[response.code]
        raise_handled_error(response.code, error)
      elsif %w{0 200}.include?(response.code)
        data = JSON.parse(response.body)
        code = data.fetch('loginResponse',{})['resultCode']

        if error = OpenApiError::ERROR_CODES[code.to_s]
          raise_handled_error(code, error)
        else
          data['loginResponse']['session']
        end
      else
        raise "Unknown Auth response: #{response.code}\n#{response.body}"
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
        code = data.fetch('loginResponse',{})['resultCode']

        if error = OpenApiError::ERROR_CODES[code.to_s]
          raise_handled_error(code, error)
        else
          data['loginResponse']['session']
        end
      else
        raise "Unknown Auth response: #{response.code}\n#{response.body}"
      end
    end

    def expired?
      raise "not implemented"
    end
  end

  def get_session
    @auth_session ||= AuthSession.new(@user, @password, base_url(@location)).session
  end
end
