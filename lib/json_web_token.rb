require "jwt"

# app/lib/json_web_token.rb
class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  def self.encode(payload)
    ::JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = ::JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue StandardError
    nil
  end
end
