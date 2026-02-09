# frozen_string_literal: true

require "net/http"
require "openssl"

module Herald
  class WebhookDeliveryJob < ActiveJob::Base
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 5

    def perform(event, post_id)
      return unless Herald.config.webhook_url.present?

      post = Herald::Post.find_by(id: post_id)
      return unless post

      payload = {
        event: event,
        post: {
          id: post.id,
          title: post.title,
          slug: post.slug,
          status: post.status,
          published_at: post.published_at
        }
      }.to_json

      headers = {"Content-Type" => "application/json"}

      if Herald.config.webhook_secret.present?
        signature = OpenSSL::HMAC.hexdigest("SHA256", Herald.config.webhook_secret, payload)
        headers["X-Herald-Signature"] = signature
      end

      Rails.logger.info("[Herald] Delivering webhook to #{Herald.config.webhook_url} for event #{event}")
      Net::HTTP.post(URI(Herald.config.webhook_url), payload, headers)
      Rails.logger.info("[Herald] Webhook delivered successfully for event #{event}")
    end
  end
end
