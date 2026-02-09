# frozen_string_literal: true

module Herald
  module Api
    class PostsController < BaseController
      before_action :set_post, only: [:show, :update, :destroy]

      def index
        posts = if params[:include_drafts]
          Herald::Post.order(created_at: :desc)
        else
          Herald::Post.recently_published
        end

        posts = posts.search(params[:q])

        if params[:category_slug].present?
          category = Herald::Category.find_by(slug: params[:category_slug])
          posts = posts.for_category(category&.id)
        end

        if params[:tag_slug].present?
          tag = Herald::Tag.find_by(slug: params[:tag_slug])
          posts = posts.for_tag(tag&.id)
        end

        pagy, records = paginate(posts)
        render json: paginated_json(pagy, records.map { |post| post_json(post) })
      end

      def show
        render json: post_json(@post)
      end

      def by_slug
        post = Herald::Post.find_by!(slug: params[:slug])
        render json: post_json(post)
      end

      def bulk
        posts = Herald::Post.where(id: params[:ids])
        count = posts.count

        case params[:action_name]
        when "publish"
          posts.each { |p| p.publish! }
        when "unpublish"
          posts.update_all(status: :draft)
        when "delete"
          posts.destroy_all
        else
          return render json: {error: "Invalid action"}, status: :unprocessable_entity
        end

        render json: {count: count}
      end

      def create
        post = Herald::Post.new(post_params)
        post.user = herald_author
        post.published_at = Time.current if post.published?

        if post.save
          render json: post_json(post), status: :created
        else
          render json: {errors: post.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        @post.published_at ||= Time.current if post_params[:status] == "published"

        if @post.update(post_params)
          render json: post_json(@post)
        else
          render json: {errors: @post.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Herald::Post.find(params[:id])
      end

      def post_params
        params.require(:herald_post).permit(:title, :body, :excerpt, :meta_description, :og_image, :status, category_ids: [])
      end

      def post_json(post)
        {
          id: post.id,
          title: post.title,
          slug: post.slug,
          excerpt: post.excerpt,
          body: post.body.to_s,
          body_plain_text: post.body.to_plain_text,
          meta_description: post.meta_description,
          status: post.status,
          published_at: post.published_at,
          author: post.user.name,
          pinned: post.pinned,
          featured_image_url: post.featured_image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(post.featured_image, only_path: true) : nil,
          categories: post.categories.map { |c| {id: c.id, name: c.name, slug: c.slug} },
          tags: post.tags.map { |t| {id: t.id, name: t.name, slug: t.slug} },
          reading_time: post.reading_time,
          created_at: post.created_at,
          updated_at: post.updated_at
        }
      end
    end
  end
end
