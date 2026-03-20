# frozen_string_literal: true

require "test_helper"

class Herald::Api::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "API User", email: "api@example.com")
    sign_in @user
    @category = Herald::Category.create!(name: "Tech")
  end

  test "index returns categories with pagination" do
    get herald.api_post_categories_path, as: :json
    assert_response :success
    assert_includes response.parsed_body["data"].pluck("name"), "Tech"
    meta = response.parsed_body["meta"]
    assert_equal 1, meta["page"]
    assert_equal 1, meta["total_pages"]
    assert_equal 1, meta["total_count"]
  end

  test "show returns category" do
    get herald.api_post_category_path(@category), as: :json
    assert_response :success
    assert_equal "Tech", response.parsed_body["name"]
  end

  test "create with valid params" do
    assert_difference("Herald::Category.count") do
      post herald.api_post_categories_path, params: {
        herald_category: {name: "Design", description: "Design articles"}
      }, as: :json
    end
    assert_response :created
    assert_equal "Design", response.parsed_body["name"]
  end

  test "create with invalid params returns errors" do
    post herald.api_post_categories_path, params: {
      herald_category: {name: ""}
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "update category" do
    patch herald.api_post_category_path(@category), params: {
      herald_category: {name: "Technology"}
    }, as: :json
    assert_response :success
    assert_equal "Technology", @category.reload.name
  end

  test "destroy category" do
    assert_difference("Herald::Category.count", -1) do
      delete herald.api_post_category_path(@category), as: :json
    end
    assert_response :no_content
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
