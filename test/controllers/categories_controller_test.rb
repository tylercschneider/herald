# frozen_string_literal: true

require "test_helper"

class Herald::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com")
    sign_in @user
    @category = Herald::Category.create!(name: "Tech")
  end

  test "index lists categories" do
    get herald.categories_path
    assert_response :success
    assert_match "Tech", response.body
  end

  test "new renders form" do
    get herald.new_category_path
    assert_response :success
    assert_select "form"
  end

  test "create with valid params" do
    assert_difference("Herald::Category.count") do
      post herald.categories_path, params: {herald_category: {name: "Design"}}
    end
    assert_redirected_to herald.categories_path
  end

  test "create with invalid params" do
    assert_no_difference("Herald::Category.count") do
      post herald.categories_path, params: {herald_category: {name: ""}}
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    get herald.edit_category_path(@category)
    assert_response :success
    assert_select "form"
  end

  test "update with valid params" do
    patch herald.category_path(@category), params: {herald_category: {name: "Technology"}}
    assert_redirected_to herald.categories_path
    assert_equal "Technology", @category.reload.name
  end

  test "destroy deletes category" do
    assert_difference("Herald::Category.count", -1) do
      delete herald.category_path(@category)
    end
    assert_redirected_to herald.categories_path
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
