# frozen_string_literal: true

module Herald
  module Api
    class BaseController < ::ApplicationController
      include Pagy::Method

      before_action :herald_api_authenticate!

      private

      def herald_api_authenticate!
        send(Herald.config.api_authentication_method)
      end

      def herald_author
        send(Herald.config.current_author_method)
      end

      def paginate(collection)
        options = {}
        options[:limit] = params[:per_page].to_i if params[:per_page].present?
        pagy(collection, **options)
      end

      def paginated_json(pagy, data)
        {
          data: data,
          meta: {
            page: pagy.page,
            total_pages: pagy.pages,
            total_count: pagy.count
          }
        }
      end
    end
  end
end
