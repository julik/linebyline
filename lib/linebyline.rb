module LineByLine
  
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
    
    def eof?
      ref_line.nil? && output_line.nil?
    end
    
    def fail! with_message
      full_message = [with_message + " at line #{lineno}"]
      full_message << " + #{ref_line}"
      full_message << " - #{output_line}"
      
      @failure = full_message.join("\n")
      throw :fail
    end
  end
  
  class NotSame < RuntimeError
  end
  
  def compare_buffers!(reference_io, io_under_test)
    
    if reference_io.object_id == io_under_test.object_id
      raise NotSame, /The passed IO objects were the same thing/
    end
    
    [reference_io, io_under_test].each{|io| io.rewind }
    
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
end