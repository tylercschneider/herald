# frozen_string_literal: true

require "test_helper"

class Herald::ConfigurationTest < ActiveSupport::TestCase
  setup do
    Herald.reset_config!
  end

  teardown do
    Herald.reset_config!
  end

  test "has default author_class" do
    assert_equal "User", Herald.config.author_class
  end

  test "has default application_name" do
    assert_equal "Blog", Herald.config.application_name
  end

  test "has default authentication_method" do
    assert_equal :authenticate_user!, Herald.config.authentication_method
  end

  test "has default current_author_method" do
    assert_equal :current_user, Herald.config.current_author_method
  end

  test "has default api_authentication_method" do
    assert_equal :authenticate_api_user!, Herald.config.api_authentication_method
  end

  test "has default admin_layout" do
    assert_equal "application", Herald.config.admin_layout
  end

  test "has default blog_layout" do
    assert_equal "application", Herald.config.blog_layout
  end

  test "configure yields configuration" do
    Herald.configure do |config|
      config.author_class = "Admin"
      config.application_name = "My App"
      config.authentication_method = :require_login!
      config.current_author_method = :current_admin
      config.api_authentication_method = :api_auth!
      config.admin_layout = "admin"
      config.blog_layout = "blog"
    end

    assert_equal "Admin", Herald.config.author_class
    assert_equal "My App", Herald.config.application_name
    assert_equal :require_login!, Herald.config.authentication_method
    assert_equal :current_admin, Herald.config.current_author_method
    assert_equal :api_auth!, Herald.config.api_authentication_method
    assert_equal "admin", Herald.config.admin_layout
    assert_equal "blog", Herald.config.blog_layout
  end

  test "reset_config! restores defaults" do
    Herald.configure do |config|
      config.author_class = "Admin"
    end

    Herald.reset_config!
    assert_equal "User", Herald.config.author_class
  end
end
