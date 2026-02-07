# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper KeystoneUiHelper

  # Skip CSRF for test auth routes
  skip_forgery_protection if: -> { Rails.env.test? }

  private

  def authenticate_user!
    head :unauthorized unless current_user
  end

  def authenticate_api_user!
    head :unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
