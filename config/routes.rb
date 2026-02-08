# frozen_string_literal: true

Herald::Engine.routes.draw do
  # Public blog
  get "blog", to: "blog#index", as: :blog
  get "blog/feed", to: "blog#feed", as: :blog_feed, defaults: {format: :rss}
  get "blog/category/:slug", to: "blog#category", as: :blog_category
  get "blog/tag/:slug", to: "blog#tag", as: :blog_tag
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Admin
  resources :posts
  resources :categories, except: [:show]

  # API
  namespace :api do
    resources :posts do
      get "by_slug/:slug", action: :by_slug, on: :collection, as: :by_slug
      post :bulk, on: :collection
    end
    resources :categories
  end
end
