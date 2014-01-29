# FIXME dags
# this assumes that elements in the queue
# have a numerical member named 'score'
class PriorityQueue

  def initialize a=Array.new
    @queue = Array.new a
  end

  def sort!
    @queue.sort_by! { |i| -i.score }
  end

  def pop
    sort!
    @queue.pop
  end

  def push i
    @queue << i
  end

  def empty?
    @queue.empty?
  end

  # FIXME
  def to_s
    a = []
    @queue.each { |i|
      a << "#{i.to_s}[#{i.score}]"
    }
    "[#{a.join ', '}]"
  end
end

