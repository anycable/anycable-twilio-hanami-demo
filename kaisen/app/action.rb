# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module Kaisen
  class Action < Hanami::Action
    include Dry::Monads[:result]
    include Deps["inflector"]

    private

    def phlex(component)
      Views::Layouts::Base.new(component).call
    end
  end
end
