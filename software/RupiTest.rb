#! /usr/bin/env ruby

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require './test/TestRupiMath.rb'
require './test/TestRupiContainer.rb'
require './test/TestRupiIteration.rb'
require './test/TestRupiSelector.rb'

# RupiTest is used to test the code during each change. It's a terminal script
# which will show a menu where it possible to test each main part of the parser.
# To see each main parts, please look into RupiRun

puts "*** Test of Rupi ***"
puts "="*20
puts "1. Complete test"
puts "2. Math test"
puts "3. Container test"
puts "4. Iterator test"
puts "5. Selector test"
puts "6. General test"
puts "7. Raspberry test"
puts "8. Function test"
puts "9. Read file test"

print "Selected: "
ret_value = gets
@parser_test = Test::Unit::TestSuite.new("Parser Tester")
puts "="*20

def math_func
  @parser_test << TestMath.new('test_plus')
  @parser_test << TestMath.new('test_minus')
  @parser_test << TestMath.new('test_multi')
  @parser_test << TestMath.new('test_divide')
  @parser_test << TestMath.new('test_comp')
  @parser_test << TestMath.new('test_log')
  @parser_test << TestMath.new('test_comp_log')
  :ok
end
def container_func
  @parser_test << TestContainer.new('test_variable')
  @parser_test << TestContainer.new('test_dec_variable')
  @parser_test << TestContainer.new('test_assign_variable')
  @parser_test << TestContainer.new('test_increment_variable')
  @parser_test << TestContainer.new('test_math_variable')
  @parser_test << TestContainer.new('test_string_variable')
  @parser_test << TestContainer.new('test_array_variable')
  :ok
end
def iterator_func
  @parser_test << TestIterator.new('test_for_iterator')
  @parser_test << TestIterator.new('test_while_iterator')
  :ok
end
def selector_func
  @parser_test << TestSelector.new('test_if_statement')
  @parser_test << TestSelector.new('test_if_else_statement')
  @parser_test << TestSelector.new('test_if_elif_statement')
  @parser_test << TestSelector.new('test_if_elif_else_statement')
  @parser_test << TestSelector.new('test_nested_if_statement')
  :ok
end
def general_func

end

# Load selection
if ret_value.to_i == 1
  math_func                   # Test Math
  container_func              # Test Container
  iterator_func               # Test Iterators
  selector_func               # Test Selector
  general_func                # Test general methods
elsif ret_value.to_i == 2
  math_func
elsif ret_value.to_i == 3
  container_func
elsif ret_value.to_i == 4
  iterator_func
elsif ret_value.to_i == 5
  selector_func
elsif ret_value.to_i == 6
  general_func
elsif ret_value.to_i == 7

elsif ret_value.to_i == 8

end

# Run the suite
Test::Unit::UI::Console::TestRunner.run(@parser_test)
