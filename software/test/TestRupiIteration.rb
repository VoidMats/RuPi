#! /usr/bin/env ruby

require 'test/unit'
require '../software/rupi.rb'

class TestIterator < Test::Unit::TestCase
  def setup
    @parser = Rupi.new
    @parser.log(false, false)
    @@our_debug = false
  end
  def test_for_iterator
    assert_equal(5, @parser.command("int _i=1; for 0,3 with _k { _i++; }; _i").value )
    assert_equal(8, @parser.command("int _j=1; for 4,10 with _k { _j++; }; _j").value )
    assert_equal(true, @parser.command("int _l = 2; array _a = [1,2,3,4,5]; for 0,4 with _k { _a.at(_l) }; ").value )
    assert_equal(15, @parser.command("int _sum=0; array _b=[1,2,3,4,5]; for 0,4 with _k { int _tmp = _a.at(_k); _sum=_sum+_tmp;  }; _sum").value )
    assert_equal(1, @parser.command("int _m = 0; for 0,0 with _idx { _m++; }; _m").value )
    assert_equal(2, @parser.command("int _n = 0; for 0,1 with _idx { _n++; string _s = \"test\"; }; _n").value )
    assert_equal(3, @parser.command("int _o = 0; for 0,2 with _idx { _o = _o+1; string _s = \"test\"; _s.add(\" more test\") }; _o").value )
    @@variable_list = [{}]
    p "*** Test 'test_for_iterator' finished ***"
  end
  def test_while_iterator
    assert_equal(2, @parser.command("int _i=0; while (2>_i) { _i++; }; _i").value )
    assert_equal(2, @parser.command("int _j=0; while (2>_j) { _j++; int _test=12; }; _j").value )
    assert_equal(4, @parser.command("array _my_array = [1,2,3,4]; int _max = _my_array.size(); int _k = 0; while( _k<_max ) { print(_my_array.at(_k) ); _k++; }; _max").value )
    @@variable_list = [{}]
    p "*** Test 'test_while_iterator' finished ***"
  end
  def test_each_iterator
    assert_equal(2, @parser.command("int _i=0; while (2>_i) { _i++; }; _i").value )
    @@variable_list = [{}]
    p "*** Test 'test_while_iterator' finished ***"
  end
end
