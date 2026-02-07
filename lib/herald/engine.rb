# frozen_string_literal: true

module Herald
  class Engine < ::Rails::Engine
    isolate_namespace Herald
  end
end
