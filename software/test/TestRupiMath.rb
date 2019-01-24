#! /usr/bin/env ruby

require 'test/unit'
require '../software/rupi.rb'

class TestMath < Test::Unit::TestCase
  def setup
    @parser = Rupi.new
    @parser.log(false, false)
    @@our_debug = false
  end
  def test_plus
    assert_equal(4, @parser.command("1+3").value )
    assert_equal(10352, @parser.command("4531+5821").value )
    assert_equal(0, @parser.command("0+0").value )
    assert_equal(8, @parser.command("-6+14").value )
    assert_equal(5, @parser.command("10+-5").value )
    assert_equal(30, @parser.command("10+5+9+6").value )
    assert_equal(9, @parser.command("4     +      5").value )
    assert_equal(14, @parser.command("(3+6)+(2+3)").value )
    puts "*** Test 'test_plus' finished ***"
  end
  def test_minus
    assert_equal(-2, @parser.command("1-3").value )
    assert_equal(1554, @parser.command("5821-4267").value )
    assert_equal(0, @parser.command("0-0").value )
    assert_equal(-20, @parser.command("-6-14").value )
    assert_equal(15, @parser.command("10-(-5)").value )
    assert_equal(-160, @parser.command("15+23+13-54-34-123").value )
    assert_equal(-52, @parser.command("15+23-(-13-54)-34-123").value )
    puts "*** Test 'test_minus' finished ***"
  end
  def test_multi
    assert_equal(2, @parser.command("1*2").value )
    assert_equal(0, @parser.command("56*0").value )
    assert_equal(3475428, @parser.command("1356*2563").value )
    assert_equal(21, @parser.command("3*6+3").value )
    assert_equal(27, @parser.command("3*(6+3)").value )
    assert_equal(-27, @parser.command("-3*9").value )
    puts "*** Test 'test_multi' finished ***"
  end
  def test_divide
    assert_equal(3, @parser.command("9/3").value )
    assert_equal(-3, @parser.command("-9/3").value )
    assert_equal(0, @parser.command("0/3").value )
    assert_equal(2,@parser.command("5/2").value )
    assert_equal(1.75,@parser.command("3.5/2").value )
    assert_equal(11, @parser.command("(23+12)/3").value )
    #assert_equal(0,@parser.command("18/0"))   TODO implement error code
    puts "*** Test 'test_divide' finished ***"
  end
  def test_comp
    assert_equal(true, @parser.command("1<2").value )
    assert_equal(false, @parser.command("2<1").value )
    assert_equal(true, @parser.command("2>1").value )
    assert_equal(false, @parser.command("1>2").value )
    assert_equal(true, @parser.command("1<=1").value )
    assert_equal(false, @parser.command("3<=1").value )
    assert_equal(true, @parser.command("1<=2").value )
    assert_equal(true, @parser.command("1>=1").value )
    assert_equal(true, @parser.command("3>=1").value )
    assert_equal(false, @parser.command("1>=2").value )
    assert_equal(true, @parser.command("1      <        4").value )
    puts "*** Test 'test_comp' finished ***"
  end
  def test_log
    assert_equal(true, @parser.command("TRUE").value )
    assert_equal(false, @parser.command("FALSE").value )
    assert_equal(true, @parser.command("TRUE && TRUE").value )
    assert_equal(false, @parser.command("FALSE && TRUE").value )
    assert_equal(false, @parser.command("TRUE && FALSE").value )
    assert_equal(false, @parser.command("FALSE && FALSE").value )
    assert_equal(true, @parser.command("TRUE || TRUE").value )
    assert_equal(true, @parser.command("FALSE || TRUE").value )
    assert_equal(true, @parser.command("TRUE || FALSE").value )
    assert_equal(false, @parser.command("FALSE || FALSE").value )
    puts "*** Test 'test_log' finished ***"
  end
  def test_comp_log
    assert_equal(true, @parser.command("1<2 && TRUE").value )
    assert_equal(false, @parser.command("TRUE && 2<1").value )
    assert_equal(false, @parser.command("3>=1 && 7<3").value )
    assert_equal(false, @parser.command("FALSE && (2<1 || 6>=3)").value )
    puts "*** Test 'test_comp_log' finished ***"
  end
end
