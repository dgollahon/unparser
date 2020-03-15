# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for case matches
    class CaseMatch < self

      handle :case_match

      children :target, :pattern, :else_branch

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CASE, WS)
        visit(target)
        nl
        visit(pattern)
        nl
        if else_branch
          write('else')
          nl
          visit(else_branch)
          nl
        end
        write('end')
      end

    end # CaseMatch
  end # Emitter
end # Unparser
