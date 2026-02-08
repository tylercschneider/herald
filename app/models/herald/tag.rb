# frozen_string_literal: true

module Herald
  class Tag < ActiveRecord::Base
    self.table_name = "herald_tags"

    has_many :post_tags, class_name: "Herald::PostTag", foreign_key: :herald_tag_id, dependent: :destroy, inverse_of: :tag
    has_many :posts, through: :post_tags

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true

    before_validation :generate_slug, on: :create

    private

    def generate_slug
      return if slug.present?
      self.slug = name.to_s.parameterize
    end
  end
end
