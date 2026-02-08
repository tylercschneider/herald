# frozen_string_literal: true

module Herald
  class PostsController < BaseController
    include ::Pagy::Method

    before_action :set_post, only: [:show, :edit, :update, :destroy]

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
        redirect_to post_path(@post), notice: "Post updated."
      else
        render :edit, status: :unprocessable_content
      end
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

    def post_params
      params.require(:herald_post).permit(:title, :body, :excerpt, :meta_description, :og_image, :status, :pinned, :tag_list, category_ids: [])
    end
  end
end
