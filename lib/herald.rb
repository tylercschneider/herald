# frozen_string_literal: true

require "herald/version"
require "herald/engine"

module Herald
  class Configuration
    attr_accessor :author_class, :application_name,
      :authentication_method, :current_author_method,
      :api_authentication_method,
      :admin_layout, :blog_layout

    def initialize
      @author_class = "User"
      @application_name = "Blog"
      @authentication_method = :authenticate_user!
      @current_author_method = :current_user
      @api_authentication_method = :authenticate_api_user!
      @admin_layout = "application"
      @blog_layout = "application"
    end
  end

  class << self
    def configure
      yield(config)
    end

    def config
      @config ||= Configuration.new
    end

    def reset_config!
      @config = Configuration.new
    end
  end
end
