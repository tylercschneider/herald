# frozen_string_literal: true

source "https://rubygems.org"

gemspec

if ENV["CI"]
  gem "keystone_components", github: "tylercschneider/keystone"
else
  gem "keystone_components", path: "../keystone"
end
gem "pg"
gem "propshaft"

group :test do
  gem "minitest"
end
