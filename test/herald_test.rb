# frozen_string_literal: true

require "test_helper"

class HeraldTest < ActiveSupport::TestCase
  test "has a version number" do
    assert Herald::VERSION
  end

  test "is a Rails engine" do
    assert Herald::Engine < Rails::Engine
  end
end
