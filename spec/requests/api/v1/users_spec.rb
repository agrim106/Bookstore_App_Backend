require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users/signup' do
    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          full_name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          mobile_number: { type: :string }
        },
        required: %w[full_name email password mobile_number]
      }

      response '201', 'User created' do
        let(:user) { { full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347' } }
        run_test!
      end

      response '422', 'Invalid user data' do
        let(:user) { { full_name: '', email: 'invalid', password: '123', mobile_number: '123' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/login' do
    post 'Logs in a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response '200', 'Login successful' do
        let(:credentials) { { email: 'kc247989@gmail.com', password: 'password123' } }
        before do
          User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') unless User.exists?(email: 'kc247989@gmail.com')
        end
        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:credentials) { { email: 'kc247989@gmail.com', password: 'wrongpassword' } }
        before do
          User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') unless User.exists?(email: 'kc247989@gmail.com')
        end
        run_test!
      end
    end
  end

  path '/api/v1/users/forgot-password' do
    post 'Sends OTP for password reset' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :email, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: ['email']
      }

      response '200', 'OTP sent' do
        let(:email) { { email: 'kc247989@gmail.com' } }
        before do
          User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') unless User.exists?(email: 'kc247989@gmail.com')
          # Mock email delivery to avoid actual sending in tests
          allow(UserMailer).to receive_message_chain(:reset_password_email, :deliver_now).and_return(true)
        end
        run_test!
      end

      response '404', 'Email not found' do
        let(:email) { { email: 'nonexistent@example.com' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/reset-password' do
    post 'Resets user password with OTP' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :reset_params, in: :body, schema: {
        type: :object,
        properties: {
          otp: { type: :string },
          new_password: { type: :string }
        },
        required: %w[otp new_password]
      }
      security [{ bearerAuth: [] }]  # Indicates JWT is required

      response '200', 'Password reset successfully' do
        let(:reset_params) { { otp: '123456', new_password: 'newpassword456' } }
        let(:user) { User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') }
        let(:token) { JwtService.encode(user_id: user.id) }
        before do
          user.update(otp: '123456', otp_expires_at: 15.minutes.from_now)
          request.headers['Authorization'] = "Bearer #{token}"
        end
        run_test!
      end

      response '422', 'Invalid or expired OTP' do
        let(:reset_params) { { otp: 'wrongotp', new_password: 'newpassword456' } }
        let(:user) { User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') }
        let(:token) { JwtService.encode(user_id: user.id) }
        before do
          user.update(otp: '123456', otp_expires_at: 15.minutes.ago)  # Expired OTP
          request.headers['Authorization'] = "Bearer #{token}"
        end
        run_test!
      end
    end
  end
end