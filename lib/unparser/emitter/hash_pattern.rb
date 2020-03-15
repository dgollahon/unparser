# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for hash patterns
    class HashPattern < self

      handle :hash_pattern

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('{')
        children.each_with_index do |child, index|
          write(', ') unless index.zero?
          visit_member(child)
        end
        write('}')
      end

      def visit_member(node)
        case node.type
        when :pair
          visit_pair(node)
        when :match_var
          visit_match_var(node)
        else
          visit(node)
        end
      end

      def visit_match_var(node)
        write_suffix_symbol(node.children.first)
      end

      def visit_pair(node)
        symbol, value = node.children

        write_suffix_symbol(symbol.children.first)
        ws

        visit(value)
      end

      def write_suffix_symbol(symbol)
        write(symbol.inspect[1..-1], ':')
      end
    end # Pin
  end # Emitter
end # Unparser
