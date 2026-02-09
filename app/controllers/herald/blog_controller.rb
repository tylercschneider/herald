# frozen_string_literal: true

module Herald
  class BlogController < ::ApplicationController
    include ::Pagy::Method

    layout -> { Herald.config.blog_layout }

    def index
      posts = Herald::Post.recently_published.includes(:categories).search(params[:q])
      @pagy, @posts = pagy(posts, limit: 20)
    end

    def show
      @post = Herald::Post.published.find_by!(slug: params[:slug])
      @meta_tags = @post.to_meta_tags
    rescue ActiveRecord::RecordNotFound
      render plain: "Not Found", status: :not_found
    end

    def category
      @category = Herald::Category.find_by!(slug: params[:slug])
      @pagy, @posts = pagy(@category.posts.recently_published, limit: 20)
    rescue ActiveRecord::RecordNotFound
      render plain: "Not Found", status: :not_found
    end

    def tag
      @tag = Herald::Tag.find_by!(slug: params[:slug])
      @pagy, @posts = pagy(@tag.posts.recently_published, limit: 20)
    rescue ActiveRecord::RecordNotFound
      render plain: "Not Found", status: :not_found
    end

    def sitemap
      @posts = Herald::Post.recently_published
      @categories = Herald::Category.joins(:posts).where(herald_posts: {status: :published}).distinct
      respond_to do |format|
        format.xml
      end
    end

    def feed
      @posts = Herald::Post.recently_published.limit(20)
      respond_to do |format|
        format.rss
      end
    end
  end
end
