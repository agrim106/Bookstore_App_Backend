class Api::V1::UsersController < ApplicationController
  include Authenticable
  skip_before_action :authenticate_user, only: [:create, :login, :forgot_password]

  def create
    user = User.new(user_params)
    if user.save
      render json: { message: "User created successfully", user: user.as_json(except: :password_digest) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: { message: "Login successful", token: token, user: user.as_json(except: :password_digest) }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def forgot_password
    user = User.find_by(email: params[:email])
    if user
      user.generate_otp
      UserMailer.reset_password_email(user).deliver_now
      render json: { message: "OTP sent to your email" }, status: :ok
    else
      render json: { error: "Email not found" }, status: :not_found
    end
  end

  def reset_password
    if current_user && current_user.valid_otp?(params[:otp])
      current_user.update(password: params[:new_password])
      current_user.update(otp: nil, otp_expires_at: nil)
      render json: { message: "Password reset successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired OTP" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :mobile_number)
  end
end