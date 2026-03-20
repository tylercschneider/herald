# frozen_string_literal: true

module Herald
  class CategoriesController < BaseController
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = Herald::Category.ordered
    end

    def new
      @category = Herald::Category.new
    end

    def create
      @category = Herald::Category.new(category_params)

      if @category.save
        redirect_to herald.post_categories_path, notice: "Category created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to herald.post_categories_path, notice: "Category updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @category.destroy
      redirect_to herald.post_categories_path, notice: "Category deleted.", status: :see_other
    end

    private

    def set_category
      @category = Herald::Category.find(params[:id])
    end

    def category_params
      params.require(:herald_category).permit(:name, :description, :position)
    end
  end
end
