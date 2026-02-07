# frozen_string_literal: true

Herald.configure do |config|
  config.author_class = "User"
  config.application_name = "Test Blog"
  config.authentication_method = :authenticate_user!
  config.current_author_method = :current_user
  config.api_authentication_method = :authenticate_api_user!
end
