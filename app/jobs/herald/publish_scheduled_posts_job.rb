# frozen_string_literal: true

module Herald
  class PublishScheduledPostsJob < ActiveJob::Base
    queue_as :default

    def perform
      Herald::Post.scheduled.where("published_at <= ?", Time.current).find_each do |post|
        post.publish!
      end
    end
  end
end
