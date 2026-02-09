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

  test "by_slug returns post by slug" do
    get herald.by_slug_api_posts_path(slug: "api-post"), as: :json
    assert_response :success
    assert_equal "API Post", response.parsed_body["title"]
    assert_equal "api-post", response.parsed_body["slug"]
  end

  test "by_slug returns 404 for unknown slug" do
    get herald.by_slug_api_posts_path(slug: "nonexistent"), as: :json
    assert_response :not_found
  end

  test "bulk publish posts" do
    post2 = Herald::Post.create!(title: "Post 2", user: @user)
    post herald.bulk_api_posts_path, params: {action_name: "publish", ids: [@post.id, post2.id]}, as: :json
    assert_response :success
    assert_equal 2, response.parsed_body["count"]
    assert @post.reload.published?
    assert post2.reload.published?
  end

  test "bulk unpublish posts" do
    @post.publish!
    post herald.bulk_api_posts_path, params: {action_name: "unpublish", ids: [@post.id]}, as: :json
    assert_response :success
    assert @post.reload.draft?
  end

  test "bulk delete posts" do
    post2 = Herald::Post.create!(title: "Post 2", user: @user)
    assert_difference("Herald::Post.count", -2) do
      post herald.bulk_api_posts_path, params: {action_name: "delete", ids: [@post.id, post2.id]}, as: :json
    end
    assert_response :success
    assert_equal 2, response.parsed_body["count"]
  end

  test "bulk with invalid action returns error" do
    post herald.bulk_api_posts_path, params: {action_name: "invalid", ids: [@post.id]}, as: :json
    assert_response :unprocessable_entity
  end

  test "show includes tags in response" do
    tag = Herald::Tag.create!(name: "Ruby")
    @post.tags << tag
    get herald.api_post_path(@post), as: :json
    assert_response :success
    tags = response.parsed_body["tags"]
    assert_equal [{"id" => tag.id, "name" => "Ruby", "slug" => "ruby"}], tags
  end

  test "show includes pinned in response" do
    @post.update!(pinned: true)
    get herald.api_post_path(@post), as: :json
    assert_response :success
    assert_equal true, response.parsed_body["pinned"]
  end

  test "show includes reading_time in response" do
    get herald.api_post_path(@post), as: :json
    assert_response :success
    assert_equal 1, response.parsed_body["reading_time"]
  end

  test "show includes featured_image_url as null when no image" do
    get herald.api_post_path(@post), as: :json
    assert_response :success
    assert_nil response.parsed_body["featured_image_url"]
  end

  test "show includes body and body_plain_text" do
    @post.update!(body: "<p>Hello <strong>world</strong></p>")
    get herald.api_post_path(@post), as: :json
    assert_response :success
    assert response.parsed_body["body"].present?
    assert_equal "Hello world", response.parsed_body["body_plain_text"]
  end

  test "show includes related_posts array" do
    category = Herald::Category.create!(name: "Ruby")
    @post.categories << category
    related = Herald::Post.create!(title: "Related API Post", user: @user, slug: "related-api-post", excerpt: "Related excerpt", status: :published, published_at: 2.days.ago)
    related.categories << category

    get herald.api_post_path(@post), as: :json
    assert_response :success
    related_posts = response.parsed_body["related_posts"]
    assert_kind_of Array, related_posts
    assert_equal 1, related_posts.size
    rp = related_posts.first
    assert_equal related.id, rp["id"]
    assert_equal "Related API Post", rp["title"]
    assert_equal "related-api-post", rp["slug"]
    assert_equal "Related excerpt", rp["excerpt"]
    assert_includes rp.keys, "published_at"
    assert_includes rp.keys, "featured_image_url"
  end

  test "by_slug includes related_posts array" do
    category = Herald::Category.create!(name: "Ruby")
    @post.categories << category
    related = Herald::Post.create!(title: "Related Slug Post", user: @user, excerpt: "Excerpt", status: :published, published_at: 2.days.ago)
    related.categories << category

    get herald.by_slug_api_posts_path(slug: @post.slug), as: :json
    assert_response :success
    assert_kind_of Array, response.parsed_body["related_posts"]
    assert_equal 1, response.parsed_body["related_posts"].size
  end

  test "index does not include related_posts" do
    @post.publish!
    get herald.api_posts_path, as: :json
    assert_response :success
    post_data = response.parsed_body["data"].first
    assert_not_includes post_data.keys, "related_posts"
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
