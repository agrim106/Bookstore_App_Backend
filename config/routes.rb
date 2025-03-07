Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # User registration (signup)
      post '/users/signup', to: 'users#create', as: 'signup'

      # User login
      post '/users/login', to: 'sessions#create', as: 'login'

      # Forgot password (password reset request)
      post '/users/forgot-password', to: 'password_resets#create', as: 'forgot_password'
      
      #Reset Password (password reset updations)
      post '/users/reset-password', to: 'password_resets#update', as: 'reset_password'
    end
  end
end