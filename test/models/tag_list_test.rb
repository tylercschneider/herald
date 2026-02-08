# frozen_string_literal: true

require "test_helper"

class Herald::TagListTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "taglist@example.com")
  end

  test "tag_list returns comma-separated tag names" do
    post = Herald::Post.create!(title: "Tagged Post", user: @user)
    post.tags.create!(name: "Ruby")
    post.tags.create!(name: "Rails")

    assert_equal "Ruby, Rails", post.tag_list
  end

  test "tag_list returns empty string when no tags" do
    post = Herald::Post.create!(title: "Untagged Post", user: @user)
    assert_equal "", post.tag_list
  end

  test "tag_list= creates new tags" do
    post = Herald::Post.create!(title: "New Tags Post", user: @user)
    post.tag_list = "Ruby, Rails, JavaScript"
    post.save!

    assert_equal 3, post.tags.count
    assert_equal ["Ruby", "Rails", "JavaScript"], post.tags.map(&:name)
  end

  test "tag_list= finds existing tags by name" do
    Herald::Tag.create!(name: "Ruby")
    post = Herald::Post.create!(title: "Existing Tags Post", user: @user)
    post.tag_list = "Ruby, Rails"
    post.save!

    assert_equal 2, post.tags.count
    assert_equal 1, Herald::Tag.where(name: "Ruby").count
  end

  test "tag_list= strips whitespace from tag names" do
    post = Herald::Post.create!(title: "Whitespace Post", user: @user)
    post.tag_list = "  Ruby ,  Rails  , JavaScript  "
    post.save!

    assert_equal ["Ruby", "Rails", "JavaScript"], post.tags.map(&:name)
  end

  test "tag_list= ignores blank entries" do
    post = Herald::Post.create!(title: "Blanks Post", user: @user)
    post.tag_list = "Ruby, , Rails, "
    post.save!

    assert_equal 2, post.tags.count
  end

  test "tag_list= replaces existing tags" do
    post = Herald::Post.create!(title: "Replace Tags Post", user: @user)
    post.tags.create!(name: "Old Tag")
    post.tag_list = "New Tag"
    post.save!

    assert_equal ["New Tag"], post.tags.map(&:name)
  end
end
