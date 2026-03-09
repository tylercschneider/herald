# frozen_string_literal: true

module Herald
  class Engine < ::Rails::Engine
    isolate_namespace Herald

    initializer "herald.url_helpers" do
      ActiveSupport.on_load(:action_controller) do
        helper Rails.application.routes.url_helpers
      end
    end

    initializer "herald.keystone_ui" do
      helper_path = KeystoneUi::Engine.root.join("app/helpers/keystone_ui_helper.rb")
      require helper_path.to_s

      theme_helper_path = root.join("app/helpers/herald/theme_helper.rb")
      require theme_helper_path.to_s

      ActiveSupport.on_load(:action_view) do
        include ::KeystoneUiHelper
        include Herald::ThemeHelper
      end
    end
  end
end
