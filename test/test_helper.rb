# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

ActiveRecord::Schema.verbose = false
load File.expand_path("dummy/db/schema.rb", __dir__)

require "rails/test_help"

class ActiveSupport::TestCase
  self.use_transactional_tests = true
end

class ActionDispatch::IntegrationTest
  private

  def sign_in(user)
    post "/test_sign_in", params: {user_id: user.id}
  end

  def sign_out
    delete "/test_sign_out"
  end
end
