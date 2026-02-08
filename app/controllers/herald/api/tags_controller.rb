# frozen_string_literal: true

module Herald
  module Api
    class TagsController < BaseController
      before_action :set_tag, only: [:show, :update, :destroy]

      def index
        pagy, records = paginate(Herald::Tag.order(:name))
        render json: paginated_json(pagy, records.map { |t| tag_json(t) })
      end

      def show
        render json: tag_json(@tag)
      end

      def create
        tag = Herald::Tag.new(tag_params)

        if tag.save
          render json: tag_json(tag), status: :created
        else
          render json: {errors: tag.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        if @tag.update(tag_params)
          render json: tag_json(@tag)
        else
          render json: {errors: @tag.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def destroy
        @tag.destroy
        head :no_content
      end

      private

      def set_tag
        @tag = Herald::Tag.find(params[:id])
      end

      def tag_params
        params.require(:herald_tag).permit(:name)
      end

      def tag_json(tag)
        {
          id: tag.id,
          name: tag.name,
          slug: tag.slug,
          created_at: tag.created_at,
          updated_at: tag.updated_at
        }
      end
    end
  end
end
