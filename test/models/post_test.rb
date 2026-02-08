# frozen_string_literal: true

require "test_helper"

class Herald::PostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = User.create!(name: "Test User", email: "test@example.com")
  end

  test "requires title" do
    post = Herald::Post.new(user: @user)
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires user" do
    post = Herald::Post.new(title: "Test Post")
    assert_not post.valid?
    assert_includes post.errors[:user], "must exist"
  end

  test "generates slug from title on create" do
    post = Herald::Post.create!(title: "My First Blog Post", user: @user)
    assert_equal "my-first-blog-post", post.slug
  end

  test "generates unique slug when duplicate exists" do
    Herald::Post.create!(title: "Duplicate Title", user: @user)
    post2 = Herald::Post.create!(title: "Duplicate Title", user: @user)
    assert_match(/\Aduplicate-title-\h+\z/, post2.slug)
  end

  test "does not overwrite slug on update" do
    post = Herald::Post.create!(title: "Original Title", user: @user)
    original_slug = post.slug
    post.update!(title: "Updated Title")
    assert_equal original_slug, post.slug
  end

  test "slug must be globally unique" do
    Herald::Post.create!(title: "Unique Post", user: @user)
    post2 = Herald::Post.new(title: "Different Title", slug: "unique-post", user: @user)
    assert_not post2.valid?
    assert_includes post2.errors[:slug], "has already been taken"
  end

  test "defaults to draft status" do
    post = Herald::Post.create!(title: "New Post", user: @user)
    assert post.draft?
    assert_not post.published?
  end

  test "publish! sets status and published_at" do
    post = Herald::Post.create!(title: "Draft Post", user: @user)
    assert_nil post.published_at

    freeze_time do
      post.publish!
      assert post.published?
      assert_equal Time.current, post.published_at
    end
  end

  test "publish! does not overwrite existing published_at" do
    original_time = 3.days.ago
    post = Herald::Post.create!(title: "Old Post", user: @user, status: :published, published_at: original_time)
    post.update!(status: :draft)
    post.publish!
    assert_in_delta original_time, post.published_at, 1.second
  end

  test "recently_published scope returns published posts ordered by published_at desc" do
    old_post = Herald::Post.create!(title: "Old", user: @user, status: :published, published_at: 1.week.ago)
    new_post = Herald::Post.create!(title: "New", user: @user, status: :published, published_at: 1.day.ago)
    Herald::Post.create!(title: "Draft", user: @user)

    results = Herald::Post.recently_published
    assert_equal [new_post, old_post], results.to_a
  end

  test "to_meta_tags returns SEO attributes" do
    post = Herald::Post.create!(
      title: "SEO Post",
      user: @user,
      excerpt: "A short excerpt",
      meta_description: "Custom meta description",
      status: :published,
      published_at: Time.current
    )

    meta = post.to_meta_tags
    assert_equal "SEO Post", meta[:title]
    assert_equal "Custom meta description", meta[:description]
    assert_equal "article", meta[:og_type]
  end

  test "to_meta_tags falls back to excerpt when no meta_description" do
    post = Herald::Post.create!(
      title: "Fallback Post",
      user: @user,
      excerpt: "The excerpt as fallback"
    )

    meta = post.to_meta_tags
    assert_equal "The excerpt as fallback", meta[:description]
  end

  test "search finds posts matching title" do
    matching = Herald::Post.create!(title: "Rails Tutorial", user: @user)
    Herald::Post.create!(title: "Unrelated Post", user: @user)

    results = Herald::Post.search("rails")
    assert_includes results, matching
    assert_equal 1, results.count
  end

  test "search finds posts matching excerpt" do
    matching = Herald::Post.create!(title: "Some Post", excerpt: "Learn about Rails", user: @user)
    Herald::Post.create!(title: "Other Post", excerpt: "Not relevant", user: @user)

    results = Herald::Post.search("rails")
    assert_includes results, matching
    assert_equal 1, results.count
  end

  test "search is case insensitive" do
    post = Herald::Post.create!(title: "Rails Tutorial", user: @user)

    assert_includes Herald::Post.search("RAILS"), post
    assert_includes Herald::Post.search("rails"), post
  end

  test "search returns all posts when query is blank" do
    Herald::Post.create!(title: "Post One", user: @user)
    Herald::Post.create!(title: "Post Two", user: @user)

    assert_equal Herald::Post.count, Herald::Post.search("").count
    assert_equal Herald::Post.count, Herald::Post.search(nil).count
  end

  test "for_category returns posts in the given category" do
    category = Herald::Category.create!(name: "Ruby")
    other_category = Herald::Category.create!(name: "Python")
    ruby_post = Herald::Post.create!(title: "Ruby Post", user: @user)
    ruby_post.categories << category
    python_post = Herald::Post.create!(title: "Python Post", user: @user)
    python_post.categories << other_category

    results = Herald::Post.for_category(category.id)
    assert_includes results, ruby_post
    assert_not_includes results, python_post
  end

  test "for_category returns all posts when category is blank" do
    post = Herald::Post.create!(title: "Any Post", user: @user)

    assert_includes Herald::Post.for_category(nil), post
    assert_includes Herald::Post.for_category(""), post
  end

  test "for_tag returns posts with the given tag" do
    tag = Herald::Tag.create!(name: "Ruby")
    other_tag = Herald::Tag.create!(name: "Python")
    ruby_post = Herald::Post.create!(title: "Ruby Post", user: @user)
    ruby_post.tags << tag
    python_post = Herald::Post.create!(title: "Python Post", user: @user)
    python_post.tags << other_tag

    results = Herald::Post.for_tag(tag.id)
    assert_includes results, ruby_post
    assert_not_includes results, python_post
  end

  test "for_tag returns all posts when tag_id is blank" do
    post = Herald::Post.create!(title: "Any Post", user: @user)

    assert_includes Herald::Post.for_tag(nil), post
    assert_includes Herald::Post.for_tag(""), post
  end

  test "pinned defaults to false" do
    post = Herald::Post.create!(title: "Regular Post", user: @user)
    assert_equal false, post.pinned
  end

  test "has_one_attached featured_image" do
    post = Herald::Post.create!(title: "Image Post", user: @user)
    assert post.respond_to?(:featured_image)
    assert_not post.featured_image.attached?
  end

  test "can be set to scheduled status" do
    post = Herald::Post.create!(title: "Future Post", user: @user, status: :scheduled, published_at: 1.day.from_now)
    assert post.scheduled?
    assert_not post.published?
    assert_not post.draft?
  end

  test "recently_published excludes scheduled posts" do
    Herald::Post.create!(title: "Published", user: @user, status: :published, published_at: 1.day.ago)
    Herald::Post.create!(title: "Scheduled", user: @user, status: :scheduled, published_at: 1.day.from_now)

    results = Herald::Post.recently_published
    assert_equal 1, results.count
    assert_equal "Published", results.first.title
  end

  test "publish_if_due! publishes scheduled post with past published_at" do
    post = Herald::Post.create!(title: "Due Post", user: @user, status: :scheduled, published_at: 1.hour.ago)
    post.publish_if_due!

    assert post.published?
  end

  test "publish_if_due! does not publish scheduled post with future published_at" do
    post = Herald::Post.create!(title: "Future Post", user: @user, status: :scheduled, published_at: 1.day.from_now)
    post.publish_if_due!

    assert post.scheduled?
    assert_not post.published?
  end

  test "publish_if_due! does nothing for draft posts" do
    post = Herald::Post.create!(title: "Draft Post", user: @user)
    post.publish_if_due!

    assert post.draft?
  end

  test "publish! enqueues webhook delivery job when webhook configured" do
    Herald.config.webhook_url = "https://example.com/webhook"
    Herald.config.webhook_secret = "secret"
    post = Herald::Post.create!(title: "Webhook Post", user: @user)

    assert_enqueued_with(job: Herald::WebhookDeliveryJob) do
      post.publish!
    end
  ensure
    Herald.reset_config!
  end

  test "publish! does not enqueue webhook when not configured" do
    post = Herald::Post.create!(title: "No Webhook Post", user: @user)

    assert_no_enqueued_jobs(only: Herald::WebhookDeliveryJob) do
      post.publish!
    end
  end

  test "recently_published orders pinned posts first" do
    old_post = Herald::Post.create!(title: "Old", user: @user, status: :published, published_at: 1.week.ago)
    new_post = Herald::Post.create!(title: "New", user: @user, status: :published, published_at: 1.day.ago)
    pinned_post = Herald::Post.create!(title: "Pinned", user: @user, status: :published, published_at: 2.weeks.ago, pinned: true)

    results = Herald::Post.recently_published
    assert_equal pinned_post, results.first
    assert_equal [pinned_post, new_post, old_post], results.to_a
  end
end
