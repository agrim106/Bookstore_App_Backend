class Api::V1::PasswordResetsController < ApplicationController
  include Authenticable
  skip_before_action :authenticate_user, only: :create
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

  def update
    # Use current_user from Authenticable instead of email lookup
    if current_user && current_user.valid_otp?(params[:otp])
      current_user.update(password: params[:new_password])
      current_user.update(otp: nil, otp_expires_at: nil)
      render json: { message: "Password reset successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired OTP" }, status: :unprocessable_entity
    end
  end
end