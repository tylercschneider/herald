# frozen_string_literal: true

module Herald
  class PostTag < ActiveRecord::Base
    self.table_name = "herald_post_tags"

    belongs_to :post, class_name: "Herald::Post", foreign_key: :herald_post_id
    belongs_to :tag, class_name: "Herald::Tag", foreign_key: :herald_tag_id

    validates :herald_tag_id, uniqueness: {scope: :herald_post_id}
  end
end
