class JwtService
  # Use credentials or a fallback secret key
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'your-secret-key-here'
  ALGORITHM = 'HS256'

  def self.encode(payload, expiry = 24.hours.from_now)
    payload[:exp] = expiry.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end