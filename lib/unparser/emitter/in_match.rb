module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class InMatch < self

      handle :in_match

      children :target, :pattern

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(target)
        ws
        write('in')
        ws
        visit(pattern)
      end
    end # InMatch
  end # Emitter
end # Unparser
