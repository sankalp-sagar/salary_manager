class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle login attempts by IP and email tuple.
  throttle("auth/login/ip_email", limit: 10, period: 10.minutes) do |req|
    next unless req.post? && req.path == "/api/v1/login"

    email = req.params["email"].to_s.downcase.strip
    "#{req.ip}:#{email}"
  end

  # Prevent refresh endpoint abuse.
  throttle("auth/refresh/ip", limit: 30, period: 5.minutes) do |req|
    req.ip if req.post? && req.path == "/api/v1/refresh"
  end

  # General API burst control.
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" }, [ { error: "Rate limit exceeded" }.to_json ]]
  end
end
