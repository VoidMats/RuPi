#! /usr/bin/env ruby

require 'test/unit'
require '../software/rupi.rb'

class TestSelector < Test::Unit::TestCase
  def setup
    @parser = Rupi.new
    @parser.log(false, false)
    @@our_debug = false
  end
  def test_if_statement
    assert_equal(true, @parser.command("if(1<2){ TRUE };").value )
    assert_equal(true, @parser.command("if(1<2) { int _a = 12; };").value )
    assert_equal(true, @parser.command("if(1<2) { int _a = 12; _a };").value )
    assert_equal(true, @parser.command("if(TRUE) { int _a = 12; int _b = 23; TRUE };").value )
    assert_equal(true, @parser.command("int _x=2; if(_x>=0) { _x--; int _b = 34; };").value )
    assert_equal(true, @parser.command("int _x2=2; if(_x2>=0) { _x2--; float _f = 3.2; };").value )
    assert_equal(true, @parser.command("int _x3=2; if(_x3>=0) { _x3--; float _f = 3.2; };").value )
    assert_equal(true, @parser.command("if(TRUE){ string _s = \"test\"; };").value )
    @@variable_list = [{}]
    p "*** Test 'test_if_statement' finished ***"
  end
  def test_if_else_statement
    assert_equal(true, @parser.command("int _x=2; if(_x>=0) { _x--; float _f = 3.2; } else { _x++; float _e = 5.5; };").value )
    assert_equal(3, @parser.command("int _i=2; if(_i<=0) { _i--; } else { _i++; }; _i").value )
    assert_equal(1, @parser.command("int _j=2; if(_j>=0) { _j--; } else { _j++; }; _j").value )
    assert_equal(35, @parser.command("int _k=2; if(TRUE) { int _a = 23; _k = _a + 12; } else { _k++; }; _k").value )
    @@variable_list = [{}]
    p "*** Test 'test_if_else_statement' finished ***"
  end
  def test_if_elif_statement
    assert_equal(1, @parser.command("int _i=2; if(_i>=0) { _i--; } elif (_i<=0) { _i++; }; _i").value )
    assert_equal(3, @parser.command("int _j=2; if(_j<=0) { _j--; } elif (_j>=0) { _j++; }; _j").value )
    assert_equal(2, @parser.command("int _k=2; if(_k<=0) { _k--; } elif (_k<=1) { _k++; }; _k").value )
    assert_equal(-2, @parser.command("int _l=-1; if(_l<=0) { _l--; float _f = 2.3; } elif (_l<=1) { _l++; float _f = 5.6; }; _l").value )
    @@variable_list = [{}]
    p "*** Test 'test_if_elif_statement' finished ***"
  end
  def test_if_elif_else_statement
    assert_equal(-2, @parser.command("int _i=-1; if(_i<=0) { _i--; } elif (_i>=0) { _i++; } else { _i= 0;}; _i").value )
    assert_equal(2, @parser.command("int _j=1; if(_j<0) { _j--; } elif (_j>0) { _j++; } else { _j = 0;}; _j").value )
    assert_equal(0, @parser.command("int _k=0; if(_k<0) { _k--; } elif (_k>0) { _k++; } else { _k=0;}; _k").value )
    assert_equal(0, @parser.command("int _l=0; if(_l<0) { _l--; float _f=2.4; } elif (_l>0) { _l++; float _f=4.5; } else { _l=0; float _f=5.6; }; _l").value )
    @@variable_list = [{}]
    p "*** Test 'test_if_elif_else_statement' finished ***"
  end
  def test_nested_if_statement
    assert_equal(5, @parser.command("int _j=1; if(_j>0) { _j--; if(_j==0) {_j=5;}; }; _j").value )
    assert_equal(5, @parser.command("int _k=1; if(_k>0) { _k--; float _f=3.4; if(_k==0) {_k=5; float _f=4.5; }; }; _k").value )
    @@variable_list = [{}]
    p "*** Test 'test_nested_if_statement' finished ***"
  end
end
