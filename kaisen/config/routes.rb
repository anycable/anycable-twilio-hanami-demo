# frozen_string_literal: true

module Kaisen
  class Routes < Hanami::Routes
    root to: "home.show"

    get "/calls/:id", to: "home.show", as: :call
    post "/calls", to: "home.create", as: :calls
  end
end
