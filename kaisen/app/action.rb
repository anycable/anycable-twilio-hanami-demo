# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module Kaisen
  class Action < Hanami::Action
    include Dry::Monads[:result]
    include Deps["inflector"]

    private

    def phlex(component: nil, action: nil, locals: nil, alert: nil, notice: nil)
      unless component
        action ||= inflector.demodulize(self.class.name)
        namespace = Views.const_get(self.class.name.gsub(/(^Kaisen::Actions::|::\w+$)/, ""))
        class_name = inflector.classify(action.to_s)
        component_class = namespace.const_get(class_name)

        component = locals ? component_class.new(**locals) : component_class.new
      end

      Views::Layouts::Base.new(component, alert:, notice:).call
    end
  end
end
