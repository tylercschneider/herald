# frozen_string_literal: true

module Herald
  class Revision < ActiveRecord::Base
    self.table_name = "herald_revisions"

    belongs_to :post, class_name: "Herald::Post", foreign_key: :herald_post_id
    belongs_to :user, class_name: -> { Herald.config.author_class }.call

    validates :title, presence: true

    default_scope { order(created_at: :desc) }
  end
end
