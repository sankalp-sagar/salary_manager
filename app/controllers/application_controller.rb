class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def authorize_admin!
    render json: { error: "Forbidden" }, status: :forbidden unless current_user&.admin?
  end
end
