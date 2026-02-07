# frozen_string_literal: true

Rails.application.routes.draw do
  mount Herald::Engine => "/herald"

  # Test authentication routes
  post "test_sign_in", to: "test_auth#sign_in"
  delete "test_sign_out", to: "test_auth#sign_out"
end
