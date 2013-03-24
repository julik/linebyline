module LineByLine
  
  VERSION = '1.0.0'
  
  # The class that handles the actual checks between two lines
  class Checker < Struct.new(:lineno, :ref_line, :output_line)
    
    attr_reader :failure
    
    def register_mismatches!
      catch :fail do
        if ref_line.nil? && output_line
          fail! "Reference buffer ended, but the output still has data"
        end
      
        if ref_line && output_line.nil?
          fail! "Reference contains chars, while the output buffer ended"
        end
      
        if ref_line != output_line
          min_len = [ref_line.length, output_line.length].sort.shift
          min_len.times do | offset |
            if ref_line[offset..offset] != output_line[offset..offset]
              fail! "Line mismatch at column #{offset + 1}"
            end
          end
          fail! "Lines have different lengths (%d expected, but was %d)" % [ref_line.length, output_line.length]
        end
      end
    end
    
    # Returns true if both lines are nil
    def eof?
      ref_line.nil? && output_line.nil?
    end
    
    # Records the failure and the details on where it occurred in the buffer
    # into the @failure ivar
    def fail! with_message
      full_message = [with_message + " at line #{lineno}"]
      full_message << " + #{ref_line.inspect}"
      full_message << " - #{output_line.inspect}"
      
      @failure = full_message.join("\n")
      throw :fail
    end
  end
  
  class NotSame < RuntimeError
  end
  
  # Compares two passed String or IO objects for equal content.
  # If the contents does not match, a NotSame exception will be raised, and
  # it's +NotSame#message+ will contain a very specific description of the mismatch,
  # including the line number and offset into the line.
  def compare_buffers!(expected, actual)
    
    if expected.object_id == actual.object_id
      raise NotSame, /The passed IO objects were the same thing/
    end
    
    # Wrap the passed strings in IOs if necessary
    reference_io, io_under_test = [expected, actual].map do | str_or_io |
      str_or_io.respond_to?(:gets) ? str_or_io : StringIO.new(str_or_io)
    end
    
    # There are subtle differences in how IO is handled on dfferent platforms (Darwin)
    lineno = 0
    loop do
      # Increment the line counter
      lineno += 1
      
      checker = Checker.new(lineno, reference_io.gets, io_under_test.gets)
      if checker.eof?
        return
      else
        checker.register_mismatches!
        raise NotSame, checker.failure if checker.failure
      end
    end
  end 
  
  module Assertions
    def self.included(into)
      into.send(:include, LineByLine)
    end
    
    def assert_same_buffer(ref_buffer, actual_buffer, message = "The line should be identical but was not")
      begin
        compare_buffers! ref_buffer, actual_buffer
        assert true
      rescue NotSame => e
        flunk [message, e.message].join("\n")
      end
    end
  end
end