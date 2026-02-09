# frozen_string_literal: true

require "test_helper"

class Herald::RevisionTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com")
    @post = Herald::Post.create!(title: "Original Title", excerpt: "Original excerpt", user: @user)
  end

  test "revision belongs to post and user" do
    revision = Herald::Revision.create!(
      post: @post,
      user: @user,
      title: "Original Title",
      excerpt: "Original excerpt",
      body_text: ""
    )
    assert_equal @post, revision.post
    assert_equal @user, revision.user
  end

  test "updating post title creates a revision" do
    assert_difference("Herald::Revision.count") do
      @post.update!(title: "Updated Title")
    end

    revision = Herald::Revision.last
    assert_equal "Original Title", revision.title
    assert_equal "Original excerpt", revision.excerpt
    assert_equal @post, revision.post
    assert_equal @user, revision.user
  end

  test "updating post excerpt creates a revision" do
    assert_difference("Herald::Revision.count") do
      @post.update!(excerpt: "New excerpt")
    end

    revision = Herald::Revision.last
    assert_equal "Original excerpt", revision.excerpt
  end

  test "updating non-content fields does not create a revision" do
    assert_no_difference("Herald::Revision.count") do
      @post.update!(pinned: true)
    end
  end

  test "post has many revisions ordered by created_at desc" do
    @post.update!(title: "Second Title")
    @post.update!(title: "Third Title")

    assert_equal 2, @post.revisions.count
    assert_equal "Second Title", @post.revisions.first.title
    assert_equal "Original Title", @post.revisions.last.title
  end
end
