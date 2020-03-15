require 'anima'
require 'unparser'
require 'unparser/cli'

## TODO BEFORE MERGE
# * capture multiple assert_parses calls per test, currently last is captured

$: << __dir__

testBuilder = Class.new(Parser::Builders::Default)
testBuilder.modernize

MODERN_ATTRIBUTES = testBuilder.instance_variables.map do |instance_variable|
  attribute_name = instance_variable.to_s[1..-1].to_sym
  [attribute_name, testBuilder.public_send(attribute_name)]
end.to_h

def default_builder_attributes
  MODERN_ATTRIBUTES.keys.map do |attribute_name|
    [attribute_name, Parser::Builders::Default.public_send(attribute_name)]
  end.to_h
end

class Test
  include Adamantium::Flat, Anima.new(:default_builder_attributes, :name, :node, :parser_source, :rubies)

  TARGET_RUBIES = %w[2.5 2.6 2.7]

  EXPECT_FAILURE = {
    test_bug_def_empty_else:                     'invalid syntax',
    test_bug_480:                                'triage TODO',
    test_dedenting_heredoc:                      'triage TODO',
    test_bug_heredoc_do:                         'heredoc shit',
    test_non_lvar_injecting_match:               'unsupported dynstr TODO',
    test_pattern_matching_hash_with_string_keys: 'unsupported dynstr TODO',
    test_regex_interp:                           'unsupported dynstr TODO',
    test_ruby_bug_11873_a:                       'parens special case TODO'
  }

  def legacy_attributes
    default_builder_attributes.select do |attribute_name, value|
      !MODERN_ATTRIBUTES.fetch(attribute_name).equal?(value)
    end.to_h
  end
  memoize :legacy_attributes

  def legacy_attributes?
    !legacy_attributes.empty?
  end

  def success?
    validation.success?
  end

  def expect_failure?
    EXPECT_FAILURE.key?(name)
  end

  def allow_ruby?
    rubies.empty? || rubies.any?(TARGET_RUBIES.method(:include?))
  end

  def right(value)
    MPrelude::Either::Right.new(value)
  end

  def validation
    identification   = name.to_s
    generated_source = Unparser.unparse_either(node)
    generated_node   = generated_source.lmap{ |_value| }.bind do |source|
      MPrelude::Either.wrap_error(Parser::SyntaxError) do
        parser.parse(Unparser.buffer(source, identification))
      end
    end

    Unparser::Validation.new(
      generated_node:   generated_node,
      generated_source: generated_source,
      identification:   identification,
      original_node:    right(node),
      original_source:  right(parser_source)
    )
  end
  memoize :validation

  def parser
    Unparser.parser.tap do |parser|
      %w(foo bar baz).each(&parser.static_env.method(:declare))
    end
  end
end

class Execution
  include Anima.new(:number, :total, :test)

  def call
    if test.legacy_attributes?
      print('Skip', "Legacy parser attributes: #{test.legacy_attributes}")
      return
    end

    unless test.allow_ruby?
      print('Skip', "Non targeted rubies: #{test.rubies.join(',')}")
      return
    end

    if test.expect_failure?
      expect_failure
    else
      expect_success
    end
  end

private

  def expect_failure
    if test.success?
      fail format('Expected Failure', 'but got success')
    else
      print('Expected Failure')
    end
  end

  def expect_success
    if test.success?
      print('Success')
    else
      puts(test.validation.report)
      fail format('Failure')
    end
  end

  def format(status, message = '')
    '%3d/%3d: %-16s %s %s' % [number, total, status, test.name, message]
  end

  def print(status, message = '')
    puts(format(status, message))
  end
end

module Minitest
  class Test
  end # Test
end # Minitest

module Extractor
  TESTS = []

  class Capture
    include Anima.new(*%i[default_builder_attributes node parser_source rubies])
  end

  def self.capture(**attributes)
    @captured = Capture.new(attributes)
  end

  def self.reset
    @captured = nil
  end

  def self.call(name)
    TestParser.new.send(name)

    if @captured
      TESTS << Test.new(name: name, **@captured.to_h)
    end
  end
end

require '../parser/test/parse_helper.rb'
require '../parser/test/test_parser.rb'

module ParseHelper
  def assert_diagnoses(*arguments)
    Extractor.reset
  end

  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end

  def assert_parses(node, parser_source, _diagnostics = nil, rubies = [])
    Extractor.capture(
      default_builder_attributes: default_builder_attributes,
      node:                       node,
      rubies:                     rubies,
      parser_source:              parser_source
    )
  end

  def test_clrf_line_endings(*arguments)
    Extractor.reset
  end

  def with_versions(*arguments)
    Extractor.reset
  end

  def assert_context(*arguments)
    Extractor.reset
  end

  def refute_diagnoses(*arguments)
    Extractor.reset
  end

  def assert_diagnoses_many(*arguments)
    Extractor.reset
  end
end

TestParser.instance_methods.grep(/\Atest_/).each(&Extractor.method(:call))

puts "Extracted: #{Extractor::TESTS.length} tests from parser"

Extractor::TESTS.sort_by(&:name).each_with_index do |test, index|
  Execution.new(number: index.succ, total:  Extractor::TESTS.length, test: test).call
end
