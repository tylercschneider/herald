# frozen_string_literal: true

require "test_helper"

class Herald::PublishScheduledPostsJobTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "job@example.com")
  end

  test "publishes scheduled posts with past published_at" do
    post = Herald::Post.create!(title: "Due Post", user: @user, status: :scheduled, published_at: 1.hour.ago)

    Herald::PublishScheduledPostsJob.perform_now

    assert post.reload.published?
  end

  test "does not publish scheduled posts with future published_at" do
    post = Herald::Post.create!(title: "Future Post", user: @user, status: :scheduled, published_at: 1.day.from_now)

    Herald::PublishScheduledPostsJob.perform_now

    assert post.reload.scheduled?
  end

  test "does not affect draft or published posts" do
    draft = Herald::Post.create!(title: "Draft", user: @user)
    published = Herald::Post.create!(title: "Published", user: @user, status: :published, published_at: 1.day.ago)

    Herald::PublishScheduledPostsJob.perform_now

    assert draft.reload.draft?
    assert published.reload.published?
  end
end
