# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class MatchRest < self

      handle :match_rest

      MAP = {
        array_pattern: '*',
        hash_pattern:  '**'
      }.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(MAP.fetch(parent_type))
      end
    end # MatchRest
  end # Emitter
end # Unparser
