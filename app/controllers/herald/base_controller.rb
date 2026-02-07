# frozen_string_literal: true

module Herald
  class BaseController < ::ApplicationController
    before_action :herald_authenticate!

    layout -> { Herald.config.admin_layout }

    private

    def herald_authenticate!
      send(Herald.config.authentication_method)
    end

    def herald_author
      send(Herald.config.current_author_method)
    end
  end
end
