# frozen_string_literal: true

require "test_helper"
require "net/http"

class Herald::WebhookDeliveryJobTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "webhook@example.com")
    @post = Herald::Post.create!(title: "Webhook Post", user: @user)
    Herald.config.webhook_url = "https://example.com/webhook"
    Herald.config.webhook_secret = "test_secret"
    @sent_requests = []
  end

  teardown do
    Herald.reset_config!
  end

  test "sends POST request with correct payload and signature" do
    capture_http_posts do
      Herald::WebhookDeliveryJob.perform_now("post.published", @post.id)
    end

    assert_equal 1, @sent_requests.size
    req = @sent_requests.first

    assert_equal URI("https://example.com/webhook"), req[:uri]

    parsed = JSON.parse(req[:body])
    assert_equal "post.published", parsed["event"]
    assert_equal @post.id, parsed["post"]["id"]
    assert_equal "Webhook Post", parsed["post"]["title"]
    assert_equal "webhook-post", parsed["post"]["slug"]

    expected_sig = OpenSSL::HMAC.hexdigest("SHA256", "test_secret", req[:body])
    assert_equal expected_sig, req[:headers]["X-Herald-Signature"]
  end

  test "skips delivery when webhook_url not configured" do
    Herald.config.webhook_url = nil

    capture_http_posts do
      Herald::WebhookDeliveryJob.perform_now("post.published", @post.id)
    end

    assert_empty @sent_requests
  end

  test "omits signature header when webhook_secret not configured" do
    Herald.config.webhook_secret = nil

    capture_http_posts do
      Herald::WebhookDeliveryJob.perform_now("post.published", @post.id)
    end

    assert_equal 1, @sent_requests.size
    assert_nil @sent_requests.first[:headers]["X-Herald-Signature"]
  end

  test "network errors bubble up from perform for ActiveJob retry" do
    job = Herald::WebhookDeliveryJob.new

    Net::HTTP.define_singleton_method(:post) do |_uri, _body, _headers|
      raise SocketError, "Failed to connect"
    end

    assert_raises(SocketError) do
      job.perform("post.published", @post.id)
    end
  ensure
    Net::HTTP.define_singleton_method(:post) do |uri, body, headers = {}|
      Net::HTTPOK.new("1.1", "200", "OK")
    end
  end

  private

  def capture_http_posts
    requests = @sent_requests
    original_post = Net::HTTP.method(:post)
    Net::HTTP.define_singleton_method(:post) do |uri, body, headers = {}|
      requests << {uri: uri, body: body, headers: headers}
      Net::HTTPOK.new("1.1", "200", "OK")
    end
    yield
  ensure
    Net::HTTP.define_singleton_method(:post, original_post)
  end
end
