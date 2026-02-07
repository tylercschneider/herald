# frozen_string_literal: true

module Herald
  module Api
    class BaseController < ::ApplicationController
      before_action :herald_api_authenticate!

      private

      def herald_api_authenticate!
        send(Herald.config.api_authentication_method)
      end

      def herald_author
        send(Herald.config.current_author_method)
      end
    end
  end
end
