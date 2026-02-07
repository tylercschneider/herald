# frozen_string_literal: true

class User < ApplicationRecord
  has_many :herald_posts, class_name: "Herald::Post", dependent: :destroy
end
