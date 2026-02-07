# frozen_string_literal: true

module Herald
  class Category < ActiveRecord::Base
    self.table_name = "herald_categories"

    has_many :post_categories, class_name: "Herald::PostCategory", foreign_key: :herald_category_id, dependent: :destroy, inverse_of: :category
    has_many :posts, through: :post_categories

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true

    scope :ordered, -> { order(:position) }

    before_validation :generate_slug, on: :create

    private

    def generate_slug
      return if slug.present?
      self.slug = name.to_s.parameterize
    end
  end
end
