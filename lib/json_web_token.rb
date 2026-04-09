require "jwt"

class JsonWebToken
  class DecodeError < StandardError; end

  ALGORITHM = "HS256"
  ISSUER = ENV.fetch("JWT_ISSUER", "salary_manager_api").freeze
  AUDIENCE = ENV.fetch("JWT_AUDIENCE", "salary_manager_client").freeze
  ACCESS_TOKEN_TTL = ENV.fetch("JWT_ACCESS_TOKEN_TTL_SECONDS", "900").to_i.seconds

  def self.encode(payload = {}, expires_in: ACCESS_TOKEN_TTL, **extra_payload)
    now = Time.current.to_i
    claims = payload.to_h.merge(extra_payload).merge(
      iat: now,
      exp: (Time.current + expires_in).to_i,
      iss: ISSUER,
      aud: AUDIENCE,
      jti: SecureRandom.uuid
    )

    ::JWT.encode(claims, secret_key, ALGORITHM)
  end

  def self.decode(token)
    raise DecodeError, "Missing token" if token.blank?

    decoded = ::JWT.decode(
      token,
      secret_key,
      true,
      algorithm: ALGORITHM,
      verify_iss: true,
      iss: ISSUER,
      verify_aud: true,
      aud: AUDIENCE
    )[0]

    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidAudError => e
    raise DecodeError, e.message
  end

  def self.secret_key
    ENV["JWT_SECRET_KEY"].presence || Rails.application.secret_key_base
  end
end
