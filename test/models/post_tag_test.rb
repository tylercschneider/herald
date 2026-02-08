# frozen_string_literal: true

require "test_helper"

class Herald::PostTagTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "posttag@example.com")
    @post = Herald::Post.create!(title: "Tagged Post", user: @user)
    @tag = Herald::Tag.create!(name: "Ruby")
  end

  test "post has many tags through post_tags" do
    @post.tags << @tag
    assert_includes @post.tags, @tag
  end

  test "tag has many posts through post_tags" do
    @post.tags << @tag
    assert_includes @tag.posts, @post
  end

  test "prevents duplicate post-tag associations" do
    Herald::PostTag.create!(post: @post, tag: @tag)
    duplicate = Herald::PostTag.new(post: @post, tag: @tag)
    assert_not duplicate.valid?
  end
end
