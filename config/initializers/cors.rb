default_origins = [ "http://localhost:3000" ]
allowed_origins = ENV.fetch("ALLOWED_CORS_ORIGINS", default_origins.join(",")).split(",").map(&:strip).reject(&:blank?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      max_age: 600
  end
end
