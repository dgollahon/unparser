# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for simple nodes that generate a single token
    class Simple < self
      include Terminated

      MAP = IceNine.deep_freeze(
        forward_args:      '...',
        kwnilarg:          '**nil',
        match_nil_pattern: '**nil'
      )

      handle(*MAP.keys)

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(MAP.fetch(node_type))
      end
    end # Simple
  end # Emitter
end # Unparser
