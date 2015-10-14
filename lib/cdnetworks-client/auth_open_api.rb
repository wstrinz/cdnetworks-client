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
      handle_auth_response 'login', post_data("#{@base_url}#{LOGIN_URL}", params)
    end

    def logout
      params = {
        user: @user,
        pass: @pass,
        output: "json"
      }
      response = post_data("#{@base_url}#{LOGOUT_URL}", params)

      handle_auth_response('logout', response)
    end

    def post_data(path, params)
      uri = URI(path)
      Net::HTTP.start(uri.host, uri.port,
                                 :use_ssl => uri.scheme == 'https') do |http|

        request = Net::HTTP::Post.new uri.to_s
        request.set_form_data(params)

        http.request request # Net::HTTPResponse object
      end
    end

    def handle_auth_response(type, response)
      if error = OpenApiError::ERROR_CODES[response.code.to_s]
        raise_handled_error(response.code, error)
      elsif %w{0 200}.include?(response.code.to_s)

        data = JSON.parse(response.body)
        code = data.fetch("#{type}Response",{})['returnCode']

        if error = OpenApiError::ERROR_CODES[code.to_s]
          raise_handled_error(code, error)
        else
          data["#{type}Response"]['session']
        end
      else
        raise OpenApiError::ApiError.new("Unknown Auth response: #{response.code}\n#{response.body}")
      end
    end

    def expired?
      raise "not implemented"
    end
  end

  def get_session_token(reset_session = false, keynum = 0)
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
