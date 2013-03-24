require 'helper'
require 'stringio'

class TestAssertions < Test::Unit::TestCase
  include LineByLine::Assertions
  
  def test_nothing_raises
    assert_same_buffer "foo", "foo"
  end
  
  class Refuter
    include LineByLine::Assertions
    
    attr_reader :m
    def flunk(m)
      @m = m
    end
    
    def perform
      assert_same_buffer "foo\nbar\nbaz", "foo\nbar", "Total fail"
    end
  end
  
  def test_not_same
    r = Refuter.new
    message = 'Total fail
Lines have different lengths (4 expected, but was 3) at line 2
 + "bar\n"
 - "bar"'

    r.perform
    assert_equal message, r.m
  end
end
