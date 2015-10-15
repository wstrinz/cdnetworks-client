module AuthOpenApi
  LOGIN_URL = "/api/rest/login"
  LOGOUT_URL = "/api/rest/logout"

  class AuthSession
    def raise_handled_error(code, desc)
      raise OpenApiError::ApiError.new("Auth error: #{code} - #{desc}")
    end

    def initialize(user, pass, client)
      @user = user
      @pass = pass
      @client = client
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
      resp = @client.call(LOGIN_URL, params)

      resp[:body]['loginResponse']['session']
    end

    def logout
      params = {
        user: @user,
        pass: @pass,
        output: "json"
      }

      resp = @client.call(LOGOUT_URL, params)
      resp[:body]['logoutResponse']
    end
  end

  def get_session_token(reset_session = false, keynum = 0)
    if !@auth_session || reset_session
      @auth_session = AuthSession.new(@user, @password, self)
    end

    session = Array.wrap(@auth_session.session)[keynum]

    if session.is_a?(Hash)
      session['sessionToken']
    else
      nil
    end
  end
end
