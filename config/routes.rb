Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      post '/users/signup', to: 'users#create', as: 'signup'
      post '/users/login', to: 'users#login', as: 'login'  # Changed from sessions#create
      post '/users/forgot-password', to: 'users#forgot_password', as: 'forgot_password'  # Changed from password_resets#create
      post '/users/reset-password', to: 'users#reset_password', as: 'reset_password'  # Changed from password_resets#update
    end
  end
end