# frozen_string_literal: true

require "test_helper"
require "generators/herald/install_generator"
require "rails/generators/test_case"

class Herald::Generators::InstallGeneratorTest < Rails::Generators::TestCase
  tests Herald::Generators::InstallGenerator
  destination File.expand_path("../../tmp/generator_test", __dir__)

  setup do
    prepare_destination
    # Create a minimal routes file for the generator to modify
    FileUtils.mkdir_p(File.join(destination_root, "config"))
    File.write(
      File.join(destination_root, "config", "routes.rb"),
      "Rails.application.routes.draw do\nend\n"
    )
  end

  test "creates migration file" do
    run_generator
    assert_migration "db/migrate/create_herald_tables.rb" do |migration|
      assert_match(/create_table :herald_posts/, migration)
      assert_match(/create_table :herald_categories/, migration)
      assert_match(/create_table :herald_post_categories/, migration)
      assert_no_match(/account/, migration)
      assert_match(/add_index :herald_posts, :slug, unique: true/, migration)
      assert_match(/add_index :herald_categories, :slug, unique: true/, migration)
    end
  end

  test "creates initializer" do
    run_generator
    assert_file "config/initializers/herald.rb" do |content|
      assert_match(/Herald\.configure/, content)
      assert_match(/config\.author_class/, content)
      assert_match(/config\.authentication_method/, content)
      assert_match(/config\.api_authentication_method/, content)
    end
  end

  test "mounts engine in routes" do
    run_generator
    assert_file "config/routes.rb" do |content|
      assert_match(/mount Herald::Engine/, content)
    end
  end
end
