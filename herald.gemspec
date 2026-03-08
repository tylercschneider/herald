# frozen_string_literal: true

require_relative "lib/herald/version"

Gem::Specification.new do |spec|
  spec.name = "herald"
  spec.version = Herald::VERSION
  spec.authors = ["Tyler Schneider"]
  spec.email = ["tylercschneider@gmail.com"]

  spec.summary = "A blog engine for Rails applications."
  spec.description = "Herald is a mountable Rails engine that provides a complete blog with admin UI, public blog, API, and RSS feed."
  spec.homepage = "https://github.com/tylercschneider/herald"
  spec.license = "MIT"

  spec.metadata["source_code_uri"] = "https://github.com/tylercschneider/herald"
  spec.metadata["changelog_uri"] = "https://github.com/tylercschneider/herald/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/tylercschneider/herald/issues"

  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["lib/**/*", "app/**/*", "config/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "pagy", ">= 6.0"
  spec.add_dependency "keystone_ui"
end
