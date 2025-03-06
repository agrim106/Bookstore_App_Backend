class Api::V1::PasswordResetsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_otp
      UserMailer.reset_password_email(user).deliver_now
      render json: { message: "OTP sent to your email" }, status: :ok
    else
      render json: { error: "Email not found" }, status: :not_found
    end
  end
end