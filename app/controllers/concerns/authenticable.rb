module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    decoded = JwtService.decode(token)
    @current_user = decoded ? User.find_by(id: decoded['user_id']) : nil

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end