class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_request
    token = bearer_token
    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id])

    return if @current_user

    render_unauthorized("Invalid token")
  rescue JsonWebToken::DecodeError
    render_unauthorized("Invalid token")
  end

  def authorize_admin!
    render_forbidden("Insufficient permissions") unless current_user&.admin?
  end

  def authorize_hr!
    allowed = current_user&.hr_manager? || current_user&.admin?
    render_forbidden("Insufficient permissions") unless allowed
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end

  def render_forbidden(message = "Forbidden")
    render json: { error: message }, status: :forbidden
  end

  def render_unprocessable(errors)
    render json: { errors: Array(errors) }, status: :unprocessable_content
  end

  def render_not_found(message = "Not found")
    render json: { error: message }, status: :not_found
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)
    return nil unless scheme&.casecmp("Bearer")&.zero?

    token
  end
end
