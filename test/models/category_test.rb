# frozen_string_literal: true

require "test_helper"

class Herald::CategoryTest < ActiveSupport::TestCase
  test "requires name" do
    category = Herald::Category.new
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "generates slug from name" do
    category = Herald::Category.create!(name: "Ruby on Rails")
    assert_equal "ruby-on-rails", category.slug
  end

  test "slug must be globally unique" do
    Herald::Category.create!(name: "Tech")
    duplicate = Herald::Category.new(name: "Tech")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "ordered by position" do
    second = Herald::Category.create!(name: "Second", position: 2)
    first = Herald::Category.create!(name: "First", position: 1)

    assert_equal [first, second], Herald::Category.ordered.to_a
  end

  test "posts association through post_categories" do
    user = User.create!(name: "Author", email: "author@example.com")
    category = Herald::Category.create!(name: "Tech")
    post = Herald::Post.create!(title: "A Post", user: user)

    Herald::PostCategory.create!(post: post, category: category)

    assert_includes category.posts, post
    assert_includes post.categories, category
  end
end
