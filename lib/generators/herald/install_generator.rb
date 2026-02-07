# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Herald
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Install Herald blog engine"

      def copy_migration
        migration_template "create_herald_tables.rb.tt", "db/migrate/create_herald_tables.rb"
      end

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
        say "  1. Run migrations: rails db:migrate"
        say "  2. Configure Herald in config/initializers/herald.rb"
        say "  3. Visit /herald/blog for the public blog"
        say "  4. Visit /herald/posts for the admin interface"
      end
    end
  end
end
