# frozen_string_literal: true

module Herald
  class PostsController < BaseController
    include ::Pagy::Method

    before_action :set_post, only: [:show, :edit, :update, :destroy, :preview]

    def index
      posts = Herald::Post.search(params[:q]).for_category(params[:category]).order(created_at: :desc)
      @categories = Herald::Category.ordered
      @pagy, @posts = pagy(posts, limit: 20)
    end

    def show
    end

    def new
      @post = Herald::Post.new
    end

    def create
      @post = Herald::Post.new(post_params)
      @post.user = herald_author
      @post.published_at = Time.current if @post.published?

      assign_new_category(@post)

      if @post.save
        redirect_to post_path(@post), notice: "Post created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      @post.published_at ||= Time.current if post_params[:status] == "published"

      if @post.update(post_params)
        assign_new_category(@post)
        redirect_to post_path(@post), notice: "Post updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def preview
      render template: "herald/blog/show", layout: Herald.config.blog_layout
    end

    def destroy
      @post.destroy
      redirect_to posts_path, notice: "Post deleted.", status: :see_other
    end

    private

    def set_post
      @post = Herald::Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render plain: "Not Found", status: :not_found
    end

    def assign_new_category(post)
      name = params.dig(:herald_post, :new_category_name)
      return if name.blank?

      category = Herald::Category.find_or_create_by!(name: name.strip)
      post.categories << category unless post.categories.include?(category)
    end

    def post_params
      params.require(:herald_post).permit(:title, :slug, :body, :excerpt, :meta_description, :og_image, :status, :pinned, :featured_image, :tag_list, :published_at, category_ids: [])
    end
  end
end
