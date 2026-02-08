# frozen_string_literal: true

require "test_helper"

class Herald::TagTest < ActiveSupport::TestCase
  test "requires name" do
    tag = Herald::Tag.new
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "generates slug from name on create" do
    tag = Herald::Tag.create!(name: "Ruby on Rails")
    assert_equal "ruby-on-rails", tag.slug
  end

  test "enforces unique name" do
    Herald::Tag.create!(name: "Ruby")
    tag = Herald::Tag.new(name: "Ruby")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "enforces unique slug" do
    Herald::Tag.create!(name: "Ruby", slug: "ruby")
    tag = Herald::Tag.new(name: "Different", slug: "ruby")
    assert_not tag.valid?
    assert_includes tag.errors[:slug], "has already been taken"
  end

  test "does not overwrite slug on update" do
    tag = Herald::Tag.create!(name: "Ruby")
    original_slug = tag.slug
    tag.update!(name: "Updated Ruby")
    assert_equal original_slug, tag.slug
  end
end
