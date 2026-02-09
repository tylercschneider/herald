# frozen_string_literal: true

module Herald
  class Engine < ::Rails::Engine
    isolate_namespace Herald

    initializer "herald.url_helpers" do
      ActiveSupport.on_load(:action_controller) do
        helper Rails.application.routes.url_helpers
      end
    end
  end
end
