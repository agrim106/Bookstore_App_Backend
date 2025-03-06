class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: { message: "Login successful", token: token, user: user.as_json(except: :password_digest) }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end