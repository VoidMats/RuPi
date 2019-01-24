#! /usr/bin/env ruby

require 'test/unit'
require '../software/rupi.rb'

class TestGeneral < Test::Unit::TestCase
  def setup
    @parser = Rupi.new
    @parser.log(false, false)
    @@our_debug = false
  end
  def test_convert_obj
    assert_equal(5, @parser.command("int _i=1; for 0,3 with _k { _i++; }; _i").value )
  end
  def test_check_type

  end
  def test 

end
