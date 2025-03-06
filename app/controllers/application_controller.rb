class ApplicationController < ActionController::Base
  # Skip CSRF protection for API controllers
  skip_before_action :verify_authenticity_token, if: :api_request?

  private

  def api_request?
    request.path.start_with?('/api')
  end
end
