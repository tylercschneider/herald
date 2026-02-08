# frozen_string_literal: true

require "test_helper"

class Herald::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com")
    sign_in @user
    @post = Herald::Post.create!(title: "Existing Post", user: @user)
  end

  test "index lists posts" do
    get herald.posts_path
    assert_response :success
    assert_match "Existing Post", response.body
  end

  test "index requires authentication" do
    sign_out
    get herald.posts_path
    assert_response :unauthorized
  end

  test "new renders form" do
    get herald.new_post_path
    assert_response :success
    assert_select "form"
  end

  test "create with valid params creates post" do
    assert_difference("Herald::Post.count") do
      post herald.posts_path, params: {
        herald_post: {title: "New Blog Post", excerpt: "An excerpt"}
      }
    end
    assert_redirected_to herald.post_path(Herald::Post.last)
  end

  test "create with invalid params renders form" do
    assert_no_difference("Herald::Post.count") do
      post herald.posts_path, params: {herald_post: {title: ""}}
    end
    assert_response :unprocessable_entity
  end

  test "show displays post" do
    get herald.post_path(@post)
    assert_response :success
    assert_match "Existing Post", response.body
  end

  test "edit renders form" do
    get herald.edit_post_path(@post)
    assert_response :success
    assert_select "form"
  end

  test "update with valid params" do
    patch herald.post_path(@post), params: {herald_post: {title: "Updated Title"}}
    assert_redirected_to herald.post_path(@post)
    assert_equal "Updated Title", @post.reload.title
  end

  test "publish action publishes a draft post" do
    patch herald.post_path(@post), params: {herald_post: {status: "published"}}
    assert_redirected_to herald.post_path(@post)
    assert @post.reload.published?
  end

  test "destroy deletes post" do
    assert_difference("Herald::Post.count", -1) do
      delete herald.post_path(@post)
    end
    assert_redirected_to herald.posts_path
  end

  test "index filters posts by search query" do
    Herald::Post.create!(title: "Rails Tips", user: @user)

    get herald.posts_path, params: {q: "Rails"}
    assert_response :success
    assert_match "Rails Tips", response.body
    assert_no_match "Existing Post", response.body
  end

  test "index filters posts by category" do
    category = Herald::Category.create!(name: "Ruby")
    ruby_post = Herald::Post.create!(title: "Ruby Tips", user: @user)
    ruby_post.categories << category

    get herald.posts_path, params: {category: category.id}
    assert_response :success
    assert_match "Ruby Tips", response.body
    assert_no_match "Existing Post", response.body
  end

  test "create with tag_list creates post with tags" do
    assert_difference("Herald::Post.count") do
      post herald.posts_path, params: {
        herald_post: {title: "Tagged Post", tag_list: "Ruby, Rails"}
      }
    end
    created_post = Herald::Post.last
    assert_equal ["Ruby", "Rails"], created_post.tags.map(&:name)
  end

  test "update with tag_list updates tags" do
    @post.tag_list = "Old Tag"
    @post.save!

    patch herald.post_path(@post), params: {
      herald_post: {tag_list: "New Tag, Another"}
    }
    assert_redirected_to herald.post_path(@post)
    assert_equal ["New Tag", "Another"], @post.reload.tags.map(&:name)
  end

  test "show displays tags" do
    @post.tag_list = "Ruby, Rails"
    @post.save!

    get herald.post_path(@post)
    assert_response :success
    assert_match "Ruby", response.body
    assert_match "Rails", response.body
  end

  test "new form includes tag_list field" do
    get herald.new_post_path
    assert_response :success
    assert_match "tag_list", response.body
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
