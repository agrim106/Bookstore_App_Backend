module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info "Auth Header: #{request.headers['Authorization']}"
    Rails.logger.info "Extracted Token: #{token}"
    decoded = JwtService.decode(token)
    Rails.logger.info "Decoded Payload: #{decoded.inspect}"
    @current_user = decoded ? User.find_by(id: decoded['user_id']) : nil
    Rails.logger.info "Current User: #{@current_user.inspect}"

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end