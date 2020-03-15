# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for const pattern node
    class ConstPattern < self

      handle :const_pattern

      children :const, :pattern

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(const)
        visit(pattern)
      end
    end # ConstPattern
  end # Emitter
end # Unparser
