# frozen_string_literal: true

module Herald
  class PostCategory < ActiveRecord::Base
    self.table_name = "herald_post_categories"

    belongs_to :post, class_name: "Herald::Post", foreign_key: :herald_post_id
    belongs_to :category, class_name: "Herald::Category", foreign_key: :herald_category_id
  end
end
