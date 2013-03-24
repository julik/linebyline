require 'helper'
require 'stringio'

class TestLinebyline < Test::Unit::TestCase
  include LineByLine
  
  def test_nothing_raises
    a = "foo"
    ref = StringIO.new(a)
    another = StringIO.new(a)
    
    compare_buffers! ref, another
  end
  
  def test_works_with_string_and_io
    assert_mismatch  'foo', 'foobar' do | msg |
      assert_match /Lines have different lengths \(3 expected, but was 6\)/, msg
    end
  end
  
  def test_raises_on_pos_difference
    s = "Welcome to the house of fun"
    a = StringIO.new(s)
    a.seek(3)
    
    b = StringIO.new(s)
    
    assert_mismatch  a, b do | msg |
      assert_match /The passed IO objects were at different seek offsets \(expected: 3, actual: 0\)/, msg
    end
  end
  
  def test_raises_on_mismatch
    same = StringIO.new('dude')
    assert_mismatch  same, same do | msg |
      assert_match /The passed IO objects were the same thing/, msg
    end
    
    assert_mismatch  StringIO.new("foo"), StringIO.new("bar") do | msg |
      assert_match /Line mismatch at column 1 at line 1/, msg
    end
    
    assert_mismatch  StringIO.new("foobar"), StringIO.new("foo") do | msg |
      assert_match /Lines have different lengths \(6 expected, but was 3\) at line 1/, msg
    end
    
    assert_mismatch  StringIO.new("foo"), StringIO.new("foobar") do | msg |
      assert_match /Lines have different lengths \(3 expected, but was 6\) at line 1/, msg
    end
    
    assert_mismatch  StringIO.new("foo\nbar\n"), StringIO.new("foo\nbar\nbaz") do | msg |
      assert_match /Reference buffer ended, but the output still has data at line 3/, msg
    end
    
  end
  
  def assert_mismatch(ref, output)
    begin
      compare_buffers! ref, output
      flunk "These buffers are not the same and LineByLine should have raise"
    rescue LineByLine::NotSame => e
      yield e.message
    end
  end
end
