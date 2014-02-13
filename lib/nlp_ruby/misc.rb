class Array
  def max_index
    self.index(self.max)
  end

  def is_subset_of? other
    self.each { |i|
      if other.include? i
       return false
      end
    }
    return true
  end

  def sum
    self.inject(:+)
  end

  def mean
    self.sum.to_f/self.size
  end
end

def spawn_with_timeout cmd, t=4, debug=false
  require 'timeout'
  STDERR.write cmd+"\n" if debug
  pipe_in, pipe_out = IO.pipe
  pid = Process.spawn(cmd, :out => pipe_out)
  begin
    Timeout.timeout(t) { Process.wait pid }
  rescue Timeout::Error
    return ""
    # accept the zombies
    #Process.kill('TERM', pid)
  end
  pipe_out.close
  return pipe_in.read
end


