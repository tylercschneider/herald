# frozen_string_literal: true

module Herald
  class Post < ActiveRecord::Base
    self.table_name = "herald_posts"

    belongs_to :user, class_name: -> { Herald.config.author_class }.call

    has_many :post_categories, class_name: "Herald::PostCategory", foreign_key: :herald_post_id, dependent: :destroy, inverse_of: :post
    has_many :categories, through: :post_categories

    has_many :post_tags, class_name: "Herald::PostTag", foreign_key: :herald_post_id, dependent: :destroy, inverse_of: :post
    has_many :tags, through: :post_tags

    has_rich_text :body
    has_one_attached :featured_image

    enum :status, {draft: 0, published: 1, scheduled: 2}

    def tag_list
      tags.map(&:name).join(", ")
    end

    def tag_list=(names)
      self.tags = names.split(",").map(&:strip).reject(&:blank?).map do |name|
        Herald::Tag.find_or_create_by!(name: name)
      end
    end

    validates :title, presence: true
    validates :slug, presence: true, uniqueness: true

    scope :recently_published, -> { published.where.not(published_at: nil).order(pinned: :desc, published_at: :desc) }
    scope :for_category, ->(category_id) {
      if category_id.present?
        joins(:post_categories).where(herald_post_categories: {herald_category_id: category_id})
      else
        all
      end
    }
    scope :for_tag, ->(tag_id) {
      if tag_id.present?
        joins(:post_tags).where(herald_post_tags: {herald_tag_id: tag_id})
      else
        all
      end
    }
    scope :search, ->(query) {
      if query.present?
        q = "%#{sanitize_sql_like(query)}%"
        where("title ILIKE :q OR excerpt ILIKE :q", q: q)
      else
        all
      end
    }

    before_validation :generate_slug, on: :create

    after_commit :deliver_publish_webhook, if: -> { saved_change_to_status? && published? }

    def publish!
      self.published_at ||= Time.current
      self.status = :published
      save!
    end

    def publish_if_due!
      return unless scheduled?
      return if published_at.nil? || published_at > Time.current

      publish!
    end

    def reading_time
      text = body.to_plain_text
      words = text.split.size
      [(words / 200.0).ceil, 1].max
    end

    def to_meta_tags
      {
        title: title,
        description: meta_description.presence || excerpt,
        og_type: "article"
      }
    end

    private

    def deliver_publish_webhook
      return unless Herald.config.webhook_url.present?

      Herald::WebhookDeliveryJob.perform_later("post.published", id)
    end

    def generate_slug
      return if slug.present?

      base_slug = title.to_s.parameterize
      candidate = base_slug

      if self.class.where(slug: candidate).exists?
        candidate = "#{base_slug}-#{SecureRandom.hex(4)}"
      end

      self.slug = candidate
    end
  end
end
