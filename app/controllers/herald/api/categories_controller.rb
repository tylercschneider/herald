# frozen_string_literal: true

module Herald
  module Api
    class CategoriesController < BaseController
      before_action :set_category, only: [:show, :update, :destroy]

      def index
        categories = Herald::Category.ordered
        render json: categories.map { |c| category_json(c) }
      end

      def show
        render json: category_json(@category)
      end

      def create
        category = Herald::Category.new(category_params)

        if category.save
          render json: category_json(category), status: :created
        else
          render json: {errors: category.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: category_json(@category)
        else
          render json: {errors: @category.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_category
        @category = Herald::Category.find(params[:id])
      end

      def category_params
        params.require(:herald_category).permit(:name, :description, :position)
      end

      def category_json(category)
        {
          id: category.id,
          name: category.name,
          slug: category.slug,
          description: category.description,
          position: category.position,
          created_at: category.created_at,
          updated_at: category.updated_at
        }
      end
    end
  end
end
