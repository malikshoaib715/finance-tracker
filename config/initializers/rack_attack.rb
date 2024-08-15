# Slow down credential stuffing and sign-up spam. Limits are per IP, and for
# sign-in also per email so one address can't be hammered from many IPs.
class Rack::Attack
  AUTH_PATHS = %w[/users/sign_in /users /users/password /users/confirmation /api/v1/session].freeze

  throttle("auth/ip", limit: 10, period: 1.minute) do |request|
    request.ip if request.post? && request.path.in?(AUTH_PATHS)
  end

  throttle("sign_in/email", limit: 5, period: 5.minutes) do |request|
    if request.post? && request.path == "/users/sign_in"
      request.params.dig("user", "email").to_s.downcase.strip.presence
    elsif request.post? && request.path == "/api/v1/session"
      request.params["email"].to_s.downcase.strip.presence
    end
  end

  # Generous enough for sync bursts, low enough to stop a runaway client.
  throttle("api/token", limit: 300, period: 5.minutes) do |request|
    if request.path.start_with?("/api/") && (auth = request.get_header("HTTP_AUTHORIZATION")).present?
      Digest::SHA256.hexdigest(auth)
    end
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "content-type" => "text/plain", "retry-after" => "60" }, [ "Too many attempts. Please wait a minute and try again.\n" ] ]
  end
end
