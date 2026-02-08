# frozen_string_literal: true

require "test_helper"

class Herald::Api::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "API User", email: "api@example.com")
    sign_in @user
    @post = Herald::Post.create!(title: "API Post", user: @user, excerpt: "Excerpt")
  end

  test "index returns published posts" do
    @post.publish!
    get herald.api_posts_path, as: :json
    assert_response :success
    assert_includes response.parsed_body["data"].pluck("title"), "API Post"
  end

  test "index returns all posts when include_drafts param" do
    get herald.api_posts_path(include_drafts: true), as: :json
    assert_response :success
    assert_includes response.parsed_body["data"].pluck("title"), "API Post"
  end

  test "show returns post" do
    get herald.api_post_path(@post), as: :json
    assert_response :success
    assert_equal "API Post", response.parsed_body["title"]
    assert_equal "api-post", response.parsed_body["slug"]
  end

  test "create with valid params" do
    assert_difference("Herald::Post.count") do
      post herald.api_posts_path, params: {
        herald_post: {title: "New API Post", excerpt: "New excerpt", body: "Body content"}
      }, as: :json
    end
    assert_response :created
    assert_equal "New API Post", response.parsed_body["title"]
  end

  test "create with invalid params returns errors" do
    post herald.api_posts_path, params: {
      herald_post: {title: ""}
    }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].present?
  end

  test "create and publish in one request" do
    post herald.api_posts_path, params: {
      herald_post: {title: "Published via API", excerpt: "Excerpt", status: "published"}
    }, as: :json
    assert_response :created
    assert_equal "published", response.parsed_body["status"]
    assert_not_nil response.parsed_body["published_at"]
  end

  test "update post" do
    patch herald.api_post_path(@post), params: {
      herald_post: {title: "Updated via API"}
    }, as: :json
    assert_response :success
    assert_equal "Updated via API", @post.reload.title
  end

  test "destroy post" do
    assert_difference("Herald::Post.count", -1) do
      delete herald.api_post_path(@post), as: :json
    end
    assert_response :no_content
  end

  test "index filters by category_slug" do
    @post.publish!
    category = Herald::Category.create!(name: "Ruby")
    @post.categories << category
    Herald::Post.create!(title: "Other Post", user: @user, status: :published, published_at: 1.day.ago)

    get herald.api_posts_path(category_slug: "ruby"), as: :json
    assert_response :success
    titles = response.parsed_body["data"].pluck("title")
    assert_includes titles, "API Post"
    assert_not_includes titles, "Other Post"
  end

  test "index filters by tag_slug" do
    @post.publish!
    tag = Herald::Tag.create!(name: "Ruby")
    @post.tags << tag
    Herald::Post.create!(title: "Other Post", user: @user, status: :published, published_at: 1.day.ago)

    get herald.api_posts_path(tag_slug: "ruby"), as: :json
    assert_response :success
    titles = response.parsed_body["data"].pluck("title")
    assert_includes titles, "API Post"
    assert_not_includes titles, "Other Post"
  end

  test "index filters by search query" do
    @post.publish!
    Herald::Post.create!(title: "Rails Guide", user: @user, status: :published, published_at: 1.day.ago)

    get herald.api_posts_path(q: "Rails"), as: :json
    assert_response :success
    titles = response.parsed_body["data"].pluck("title")
    assert_includes titles, "Rails Guide"
    assert_not_includes titles, "API Post"
  end

  test "index returns pagination metadata" do
    @post.publish!
    get herald.api_posts_path, as: :json
    assert_response :success
    meta = response.parsed_body["meta"]
    assert_equal 1, meta["page"]
    assert_equal 1, meta["total_pages"]
    assert_equal 1, meta["total_count"]
  end

  test "index paginates with page and per_page params" do
    3.times { |i| Herald::Post.create!(title: "Post #{i}", user: @user, status: :published, published_at: i.days.ago) }
    get herald.api_posts_path(page: 2, per_page: 2), as: :json
    assert_response :success
    assert_equal 2, response.parsed_body["meta"]["page"]
    assert_equal 2, response.parsed_body["meta"]["total_pages"]
    assert_equal 3, response.parsed_body["meta"]["total_count"]
    assert_equal 1, response.parsed_body["data"].length
  end

  test "unauthorized without authentication" do
    sign_out
    get herald.api_posts_path, as: :json
    assert_response :unauthorized
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
