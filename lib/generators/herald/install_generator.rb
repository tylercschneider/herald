# frozen_string_literal: true

require "rails/generators"

module Herald
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install Herald blog engine"

      def copy_initializer
        template "herald.rb.tt", "config/initializers/herald.rb"
      end

      def mount_engine
        route 'mount Herald::Engine => "/herald"'
      end

      def print_instructions
        say ""
        say "Herald installed successfully!", :green
        say ""
        say "Next steps:"
        say "  1. Copy migrations: rails herald:install:migrations"
        say "  2. Run migrations: rails db:migrate"
        say "  3. Configure Herald in config/initializers/herald.rb"
        say "  4. Visit /herald/blog for the public blog"
        say "  5. Visit /herald/posts for the admin interface"
      end
    end
  end
end
