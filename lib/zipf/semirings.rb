# Semirings for directed acyclic graphs (dags) (also directed hypergraphs),
# as described in:
# 'Dynamic Programming Algorithms in
#  Semiring and Hypergraph Frameworks' (Liang Huang)
#

class Semiring
  attr_accessor :add, :multiply, :one, :null, :convert
end

class BooleanSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| a||b }
    @multiply =  Proc.new { |a,b| a&&b }
    @one = true
    @null = false
    @convert = Proc.new { |v| true && v!=0 }
  end
end

class ViterbiSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| [a,b].max }
    @multiply =  Proc.new { |a,b| a*b }
    @one = 1.0
    @null = 0.0
    @convert = Proc.new { |v| v }
  end
end

class ViterbiLogSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| [a,b].max }
    @multiply =  Proc.new { |a,b| a+b }
    @one = 0.0
    @null = -1.0/0.0
    @convert = Proc.new { |v| v }
  end
end

class InsideSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| a+b }
    @multiply =  Proc.new { |a,b| a*b }
    @one = 1.0
    @null = 0.0
    @convert = Proc.new { |v| v }
  end
end

class RealSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| [a,b].min }
    @multiply =  Proc.new { |a,b| a+b }
    @one = 0.0
    @null = 1.0/0.0
    @convert = Proc.new { |v| v }
  end
end

# for longest/worst paths
class RealxSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| [a,b].max }
    @multiply =  Proc.new { |a,b| a+b }
    @one = -1.0/0.0
    @null = 0.0
    @convert = Proc.new { |v| v }
  end
end

class CountingSemiring < Semiring
  def initialize
    @add = Proc.new { |a,b| a+b }
    @multiply =  Proc.new { |a,b| a*b }
    @one = 1.0
    @null = 0.0
    @convert = Proc.new { |v| if v!=0 then 1 else 0 end }
  end
end

