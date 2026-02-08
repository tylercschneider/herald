# frozen_string_literal: true

module Herald
  class Tag < ActiveRecord::Base
    self.table_name = "herald_tags"

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
