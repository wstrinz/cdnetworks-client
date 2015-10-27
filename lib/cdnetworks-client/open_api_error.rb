module OpenApiError
  ERROR_CODES = {
    "101" => "User login information error",
    "102" => "Invalid session",
    "103" => "Logout failure",
    "104" => "Input parameter error (no entry is made or invalid value)",
    "202" => "Inaccessible menu (Setting can be modified via Customer Portal)",
    "203" => "Inaccessible service (Setting can be modified via Customer Portal)",
    "204" => "Inaccessible Request (See Table-1. The Scope of CDNetworks Statistics Open API)",
    "301" => "Unregistered API key (Registration information is provided in Customer Portal)",
    "999" => "Temporary error"
  }

  class ApiError < StandardError

  end

  class CriticalApiError < StandardError

  end

  class ErrorHandler
    def self.handle_error_response(code, body)
      if desc = ERROR_CODES[code.to_s]
        raise ApiError.new("Open API Error #{code}: #{desc}")
      else
        raise ApiError.new("Unknown Open API Response Code #{code} (body: #{body})")
      end
    end
  end
end
