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
        # Assumes a user exists from signup or setup
        let(:credentials) { { email: 'kc247989@gmail.com', password: 'password123' } }
        before do
          # Create the user if it doesn’t exist for the test
          User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347')
        end
        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:credentials) { { email: 'kc247989@gmail.com', password: 'wrongpassword' } }
        before do
          # Ensure user exists for the negative test
          User.create!(full_name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password123', mobile_number: '9417976347') unless User.exists?(email: 'kc247989@gmail.com')
        end
        run_test!
      end
    end
  end
end