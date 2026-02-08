# frozen_string_literal: true

require "test_helper"

class Herald::Api::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "API User", email: "api@example.com")
    sign_in @user
    @tag = Herald::Tag.create!(name: "Ruby")
  end

  test "index returns tags with pagination" do
    get herald.api_tags_path, as: :json
    assert_response :success
    assert_includes response.parsed_body["data"].pluck("name"), "Ruby"
    meta = response.parsed_body["meta"]
    assert_equal 1, meta["page"]
    assert_equal 1, meta["total_pages"]
    assert_equal 1, meta["total_count"]
  end

  test "show returns tag" do
    get herald.api_tag_path(@tag), as: :json
    assert_response :success
    assert_equal "Ruby", response.parsed_body["name"]
    assert_equal "ruby", response.parsed_body["slug"]
  end

  test "create with valid params" do
    assert_difference("Herald::Tag.count") do
      post herald.api_tags_path, params: {
        herald_tag: {name: "JavaScript"}
      }, as: :json
    end
    assert_response :created
    assert_equal "JavaScript", response.parsed_body["name"]
    assert_equal "javascript", response.parsed_body["slug"]
  end

  test "create with invalid params returns errors" do
    post herald.api_tags_path, params: {
      herald_tag: {name: ""}
    }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].present?
  end

  test "create duplicate name returns errors" do
    post herald.api_tags_path, params: {
      herald_tag: {name: "Ruby"}
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "update tag" do
    patch herald.api_tag_path(@tag), params: {
      herald_tag: {name: "Ruby on Rails"}
    }, as: :json
    assert_response :success
    assert_equal "Ruby on Rails", @tag.reload.name
  end

  test "destroy tag" do
    assert_difference("Herald::Tag.count", -1) do
      delete herald.api_tag_path(@tag), as: :json
    end
    assert_response :no_content
  end

  private

  def herald
    Herald::Engine.routes.url_helpers
  end
end
