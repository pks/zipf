require 'timeout'


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

class String

  def downcase?
    self[/[[:lower:]]/]
  end
end

class PriorityQueue
# This assumes that elements in the queue
# have a numerical member named 'score'.

  def initialize a=Array.new
    @queue = Array.new a
    sort!
  end

  def sort!
    @queue.sort_by! { |i| -i.score }
  end

  def pop
    @queue.pop
  end

  def push i
    @queue << i
    sort!
  end

  def empty?
    @queue.empty?
  end
end

def spawn_with_timeout cmd, t=4, ignore_fail=false, debug=false
  STDERR.write cmd+"\n" if debug
  pipe_in, pipe_out = IO.pipe
  pid = Process.spawn(cmd, :out => pipe_out)
  begin
    Timeout.timeout(t) { Process.wait pid }
  rescue Timeout::Error
    Process.kill('TERM', pid) if !ignore_fail
  end
  pipe_out.close
  return pipe_in.read
end

def read_phrase_table fn
  table = {}
  f = ReadFile.new fn
  while raw_rule = f.gets
    french, english, features = splitpipe(raw_rule)
    feature_map = SparseVector.from_kv  features
    if table.has_key? french
      table[french] << [english, feature_map ]
    else
      table[french] = [[english, feature_map]]
    end
  end
  f.close
  return table
end

def cdec_kbest cdec_bin, input, ini, weights, k, unique=true
  require 'open3'
  cmd = "echo \"#{input}\" | #{cdec_bin} -c #{ini} -w #{weights} -k #{k}"
  cmd += " -r" if unique
  o,_ = Open3.capture2 "#{cmd}  2>/dev/null"
  a = []; j = -1
  o.split("\n").map{ |i| j+=1; t=Translation.new; t.from_s(i, false, j); a << t }
  return a
end

def read_config fn
  f = ReadFile.new fn
  cfg = {}
  while line = f.gets
    line.strip!
    next if /^\s*$/.match line
    next if line[0]=='#'
    content = line.split('#', 2).first
    k, v = content.split(/\s*=\s*/, 2)
    k.strip!; v.strip!
    cfg[k] = v
  end
  return cfg
end

