# frozen_string_literal: true

require "test_helper"

class Herald::BlogControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Author", email: "author@example.com")
    @published_post = Herald::Post.create!(
      title: "Published Post",
      user: @user,
      excerpt: "A published post",
      status: :published,
      published_at: 1.day.ago
    )
    @draft_post = Herald::Post.create!(
      title: "Draft Post",
      user: @user
    )
  end

  test "index returns success" do
    get herald.blog_path
    assert_response :success
  end

  test "index shows only published posts" do
    get herald.blog_path
    assert_match "Published Post", response.body
    assert_no_match "Draft Post", response.body
  end

  test "index does not require authentication" do
    get herald.blog_path
    assert_response :success
  end

  test "show returns success for published post" do
    get herald.blog_post_path(@published_post.slug)
    assert_response :success
    assert_match "Published Post", response.body
  end

  test "show returns 404 for draft post" do
    get herald.blog_post_path(@draft_post.slug)
    assert_response :not_found
  end

  test "show returns 404 for nonexistent slug" do
    get herald.blog_post_path("nonexistent-post")
    assert_response :not_found
  end

  test "category filters posts by category" do
    category = Herald::Category.create!(name: "Tech")
    Herald::PostCategory.create!(post: @published_post, category: category)

    get herald.blog_category_path(category.slug)
    assert_response :success
    assert_match "Published Post", response.body
  end

  test "category returns 404 for nonexistent category" do
    get herald.blog_category_path("nonexistent")
    assert_response :not_found
  end

  test "feed returns RSS" do
    get herald.blog_feed_path(format: :rss)
    assert_response :success
    assert_match "application/rss+xml", response.content_type
  end

  test "index filters posts by search query" do
    Herald::Post.create!(
      title: "Rails Guide",
      user: @user,
      status: :published,
      published_at: 2.days.ago
    )

    get herald.blog_path, params: {q: "Rails"}
    assert_response :success
    assert_match "Rails Guide", response.body
    assert_no_match "Published Post", response.body
  end

  test "feed uses Herald.config.application_name" do
    get herald.blog_feed_path(format: :rss)
    assert_match "#{Herald.config.application_name} Blog", response.body
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
