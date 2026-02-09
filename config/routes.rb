# frozen_string_literal: true

Herald::Engine.routes.draw do
  # Public blog
  get "blog", to: "blog#index", as: :blog
  get "blog/feed", to: "blog#feed", as: :blog_feed, defaults: {format: :rss}
  get "blog/atom", to: "blog#atom", as: :blog_atom, defaults: {format: :atom}
  get "blog/sitemap", to: "blog#sitemap", as: :blog_sitemap, defaults: {format: :xml}
  get "blog/category/:slug", to: "blog#category", as: :blog_category
  get "blog/tag/:slug", to: "blog#tag", as: :blog_tag
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Admin
  resources :posts do
    get :preview, on: :member
  end
  resources :categories, except: [:show]

  # API
  namespace :api do
    resources :posts do
      get "by_slug/:slug", action: :by_slug, on: :collection, as: :by_slug
      post :bulk, on: :collection
    end
    resources :categories
    resources :tags
  end
end
