# frozen_string_literal: true

class TestAuthController < ApplicationController
  def sign_in
    session[:user_id] = params[:user_id]
    head :ok
  end

  def sign_out
    session.delete(:user_id)
    head :ok
  end
end
