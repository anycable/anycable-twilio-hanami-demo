# frozen_string_literal: true

module Kaisen
  class Routes < Hanami::Routes
    root to: "calls.show"

    get "/calls", to: "calls.show", as: :calls
    get "/calls/:id", to: "calls.show", as: :call
    post "/calls", to: "calls.create"
  end
end
