#! /usr/bin/env ruby

require 'test/unit'
require '../software/rupi.rb'

class TestContainer < Test::Unit::TestCase
  def setup
    @parser = Rupi.new
    @parser.log(false, false)
    @@our_debug = false
  end
  def test_variable
    assert_equal(12, @parser.command("12").value )
    assert_equal(2.3, @parser.command("2.3").value )
    assert_equal("my_text", @parser.command("\"my_text\"").value )
    assert_equal(false, @parser.command("FALSE").value )
    assert_equal(true, @parser.command("!FALSE").value )
    p "*** Test 'test_variable' finished ***"
  end
  def test_dec_variable
    assert(@parser.command("int _test_i = 11;"),"Fail to declare int type variable")
    assert_equal(11, @parser.command("_test_i").value )
    assert_equal(11, @parser.print_value('_test_i') )
    assert_equal(true, @parser.command("string _s1 = _test_i;").value )
    assert_equal("11", @parser.command("_s1").value )
    assert_equal(true, @parser.command("float _f1 = _test_i;").value )
    assert_equal(11.0, @parser.command("_f1").value )
    exception = assert_raise(NameError) { @parser.command("int _test_i = 78;") }
    assert_equal('Variable already exist in this scope', exception.message )
    assert(@parser.command("float _test_f = 3.5;"), "Fail to declare float type variable")
    assert_equal(3.5, @parser.command("_test_f").value )
    assert_equal(3.5, @parser.print_value('_test_f') )
    assert_equal(true, @parser.command("string _s2 = _test_f;").value )
    assert_equal("3.5", @parser.command("_s2").value )
    assert_equal(true, @parser.command("int _i2 = _test_f;").value )
    assert_equal(3, @parser.command("_i2").value )
    assert(@parser.command("bool _test_b = FALSE;"), "Fail to declare bool type variable")
    assert_equal(false, @parser.command("_test_b").value )
    assert(@parser.command("string _test_s = \"aaa\";"), "Fail to declare string type variable")
    assert_equal(true, @parser.command("string _test_s2 = \"some text\"; string _test_s3 = \"extra text\";").value )
    assert_equal('some text', @parser.command("_test_s2").value )
    assert_equal('extra text', @parser.command("_test_s3").value )
    assert_equal(true, @parser.command("array _a = [1,2,3,4,5];").value )
    assert_equal([1,2,3,4,5], @parser.command("_a").value )
    assert_equal([1,2,3,4,5], @parser.print_value("_a") )
    assert_equal(true, @parser.command("array _a2 = [1, 2.3, 4, 6.3];").value )
    assert_equal([1,2.3,4,6.3], @parser.command("_a2").value )
    assert_equal([1,2.3,4,6.3], @parser.print_value("_a2") )
    p "*** Declared variables ***"
    @parser.print_global
    p "*** Test 'test_dec_variable' finished ***"
  end
  def test_assign_variable
    assert(@parser.command("_test_i = 35;"), "Fail to assign float type variable")
    assert_not_equal(11, @parser.command("_test_i").value )
    assert_equal(35, @parser.command("_test_i").value )
    assert(@parser.command("_test_f = 6.7;"), "Fail to assign float type variable")
    assert_not_equal(3.5, @parser.command("_test_f").value )
    assert_equal(6.7, @parser.command("_test_f").value )
    assert(@parser.command("_test_b = TRUE;"), "Fail to declare bool type variable")
    assert_not_equal(false, @parser.command("_test_b").value )
    assert_equal(true, @parser.command("_test_b").value )
    assert(@parser.command("_test_s = \"ccc\";"), "Fail to declare string type variable")
    assert_not_equal('aaa', @parser.command("_test_s").value )
    assert_equal('ccc', @parser.command("_test_s").value )
    assert(@parser.command("int _a_first = 104;"), "Fail to declare int type variable")
    assert_equal(true, @parser.command("int _b_second = _a_first;").value)
    assert_equal(true, @parser.command("int _c_third = 34;").value )
    assert_equal(34, @parser.command("_c_third").value )
    assert_equal(true, @parser.command("_c_third = _b_second;").value )
    assert_equal(104, @parser.command("_a_first").value )
    assert_equal(104, @parser.command("_b_second").value )
    assert_equal(104, @parser.command("_c_third").value )
    assert_equal(true, @parser.command("_a = [2,3];").value )
    assert_equal([2,3], @parser.command("_a").value )
    assert_equal([2,3], @parser.print_value('_a') )
    assert_equal(true, @parser.command("_test_i = 2.3;").value )
    assert_equal(2, @parser.command("_test_i").value )
    assert_equal(true, @parser.command("_test_f = 5;").value )
    assert_equal(5.0, @parser.command("_test_f").value )
    assert_equal(true, @parser.command("_test_s = 5;").value )
    assert_equal("5", @parser.command("_test_s").value )
    assert_equal(true, @parser.command("_test_s = 2.3;").value )
    assert_equal("2.3", @parser.command("_test_s").value )
    p "*** Assign variables ***"
    @parser.print_global
    @@variable_list = [{}]
    p "*** Test 'test_ass_variable' finished ***"
  end
  def test_increment_variable
    assert(@parser.command("int _inc_1 = 1;"), "Fail to declare int type variable")
    assert_equal(1, @parser.print_value("_inc_1") )
    assert(@parser.command("_inc_1++;"), "Fail to increase incrementor with 1")
    assert_equal(2, @parser.print_value("_inc_1") )
    assert(@parser.command("int _inc_2 = 5;"), "Fail to declare int type variable")
    assert_equal(5, @parser.print_value("_inc_2") )
    assert(@parser.command("_inc_2--;"), "Fail to decrease incrementor with 1")
    assert_equal(4, @parser.print_value("_inc_2") )
    p "*** Increment variables ***"
    @parser.print_global
    @@variable_list = [{}]
    p "*** Test 'test_increment_variable' finished ***"
  end
  def test_math_variable
    assert(@parser.command("int _a = 23;"), "Fail to declare int type variable _a")
    assert_equal(26, @parser.command("_a+3").value )
    assert(@parser.command("int _b = _a - 13;"), "Fail to declare int type variable _b")
    assert_equal(10, @parser.print_value("_b") )
    assert_equal(23, @parser.print_value("_a") )
    assert_equal(200, @parser.command("_b * 20").value )
    assert_equal(-13, @parser.command("_b - _a").value )
    assert(@parser.command("_b = _a - _b;"), "Fail to assign new value to variable _b")
    assert_equal(13, @parser.command("_b").value )
    p "*** Math variables ***"
    @parser.print_global
    @@variable_list = [{}]
    p "*** Test 'test_math_variable' finished ***"
  end
  def test_string_variable
    assert(@parser.command("string _str_1 = \"my string test\";"), "Fail to declare string" )
    assert_equal('my string test', @parser.print_value("_str_1") )
    assert_equal('my string test', @parser.command("_str_1").value )
    assert(@parser.command("_str_1 = \"new text\";"), "Fail to assign string type")
    assert_equal('new text', @parser.print_value("_str_1"))
    assert_equal('new text', @parser.command("_str_1").value )
    assert(@parser.command("_str_1.remove(0,2)"), "Fail to run String_class function remove()" )
    assert_equal(' text', @parser.command("_str_1").value )
    assert_equal(' text', @parser.print_value("_str_1") )
    assert_equal(true, @parser.command("int _i = 1;").value )
    assert_equal(true, @parser.command("_str_1.remove(_i)").value )
    assert(@parser.command("_str_1.clear()"), "Fail to run String_class function clear()" )
    assert_equal('', @parser.command("_str_1").value )
    assert_equal('', @parser.print_value('_str_1') )
    assert_equal(true, @parser.command("string _s2 = \"   test_string   \";").value )
    assert_equal(true, @parser.command("_str_1.add(_s2)").value )
    assert_equal('   test_string   ', @parser.command("_str_1").value )
    assert_equal(true, @parser.command("_str_1.rstrip()").value )
    assert_equal('   test_string', @parser.command("_str_1").value )
    assert_equal(true, @parser.command("_str_1.lstrip()").value )
    assert_equal('test_string', @parser.command("_str_1").value )
    p "*** String variables ***"
    @parser.print_global
    @@variable_list = [{}]
    p "*** Test 'test_string_variable' finished ***"
  end
  def test_array_variable
    assert(@parser.command("array _a = [1,2,3,4];"), "Fail to declare array" )
    assert_equal([1,2,3,4], @parser.command("_a").value )
    assert_equal([1,2,3,4], @parser.print_value('_a') )
    assert(@parser.command("_a.insert(6)"), "Fail to run Array_class function insert()" )
    assert_equal([6,1,2,3,4], @parser.command("_a").value )
    assert_equal([6,1,2,3,4], @parser.print_value('_a') )
    assert(@parser.command("_a.insert(3,9)"), "Fail to run Array_class function insert()" )
    assert_equal([6,1,2,9,3,4], @parser.command("_a").value )
    assert_equal([6,1,2,9,3,4], @parser.print_value('_a') )
    assert_equal(6, @parser.command("_a.size()").value )
    assert_equal(9, @parser.command("_a.at(3)").value )
    assert(@parser.command("int _i = 4;"), "Fail to declare Int_class" )
    assert_equal(3, @parser.command("_a.at(_i)").value )
    assert(@parser.command("_a.remove(1)") )
    assert(@parser.command("_i = 1;"), "Fail to assign variable" )
    assert_equal([6,2,9,3,4], @parser.command("_a").value )
    assert_equal(true, @parser.command("_a.remove(0,1)").value )
    assert_equal([9,3,4], @parser.command("_a").value )
    assert_equal(true, @parser.command("_a.remove(0,_i)").value )
    assert_equal([4], @parser.command("_a").value )
    p "*** Array variables ***"
    @parser.print_global
    @@variable_list = [{}]
    p "*** Test 'test_array_variable' finished ***"
  end
end
