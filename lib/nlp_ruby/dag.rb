module DAG

require 'json'


class DAG::Node
  attr_accessor :label, :edges, :incoming, :score, :mark

  def initialize label=nil, edges=[], incoming=[], score=nil
    @label    = label
    @edges    = edges # outgoing
    @incoming = incoming
    @score    = nil
  end

  def add_edge head, weight=0
    exit if self==head # no self-cycles!
    @edges << DAG::Edge.new(self, head, weight)
    return @edges.last
  end

  def to_s
    "DAG::Node<label:#{label}, edges:#{edges.size}, incoming:#{incoming.size}>"
  end

  def repr
    "#{to_s} #{@score} out:#{@edges} in:[#{@incoming.map{|e| e.to_s}.join ', '}]"
  end
end

class DAG::Edge
  attr_accessor :tail, :head, :weight, :mark

  def initialize tail=nil, head=nil, weight=0
    @tail   = tail
    @head   = head
    @weight = weight
    @mark   = false # did we already follow this edge? -- for topological sorting
  end

  def to_s
    s = "DAG::Edge<#{@tail} ->[#{weight}] #{@head}"
    s += " x" if @mark
    s += ">"
    s
  end
end

# depth-first search
#  w/o markings as we do not have cycles
def DAG::dfs n, target_label
  return n if n.label==target_label # assumes uniq labels!
  stack = n.edges.map { |i| i.head }
  while !stack.empty?
    m = stack.pop
    return DAG::dfs m, target_label
  end
  return nil
end

# breadth-first search
#  w/o markings as we do not have cycles
def DAG::bfs n, target_label
  queue = [n]
  while !queue.empty?
    m = queue.shift
    return m if m.label==target_label
    m.edges.each { |e| queue << e.head }
  end
  return nil
end

# topological sort
def DAG::topological_sort graph
  sorted = []
  s = graph.reject { |n| !n.incoming.empty? }
  while !s.empty?
    sorted << s.shift
    sorted.last.edges.each { |e|
      e.mark = true
      s << e.head if e.head.incoming.reject{|f| f.mark}.empty?
    }
  end
  return sorted
end

# initialize graph scores with semiring One
def DAG::init graph, semiring, source_node
  graph.each {|n| n.score=semiring.null}
  source_node.score = semiring.one
end

# viterbi
def DAG::viterbi graph, semiring=ViterbiSemiring, source_node
  toposorted = DAG::topological_sort(graph)
  DAG::init(graph, semiring, source_node)
  toposorted.each { |n|
    n.incoming.each { |e|
      # update
      n.score = \
        semiring.add.call(n.score, \
                          semiring.multiply.call(e.tail.score, e.weight)
        )
    }
  }
end

# forward viterbi
def DAG::viterbi_forward graph, semiring=ViterbiSemiring, source_node
  toposorted = DAG::topological_sort(graph)
  DAG::init(graph, semiring, source_node)
  toposorted.each { |n|
    n.edges.each { |e|
      e.head.score = \
        semiring.add.call(e.head.score, \
                          semiring.multiply.call(n.score, e.weight)
        )
    }
  }
end

# Dijkstra algorithm
#  for A*-search we would need an optimistic estimate of
#  future cost at each node
def DAG::dijkstra graph, semiring=RealSemiring.new, source_node
  DAG::init(graph, semiring, source_node)
  q = PriorityQueue.new graph
  while !q.empty?
    n = q.pop
    n.edges.each { |e|
      e.head.score = \
        semiring.add.call(e.head.score, \
                          semiring.multiply.call(n.score, e.weight))
      q.sort!
    }
  end
end

# Bellman-Ford algorithm
def DAG::bellman_ford(graph, semiring=RealSemiring.new, source_node)
  DAG::init(graph, semiring, source_node)
  edges = []
  graph.each { |n| edges |= n.edges }
  # relax edges
  (graph.size-1).times{ |i|
    edges.each { |e|
      e.head.score = \
        semiring.add.call(e.head.score, \
                          semiring.multiply.call(e.tail.score, e.weight))
    }
  }
  # we do not allow cycles (negative or positive)
end

# Floyd algorithm
def DAG::floyd(graph, semiring=nil)
  dist_matrix = []
  graph.each_index { |i|
    dist_matrix << []
    graph.each_index { |j|
      val = 1.0/0.0
      val = 0.0 if i==j
      dist_matrix.last << val
    }
  }
  edges = []
  graph.each { |n| edges |= n.edges }
  edges.each { |e|
    dist_matrix[graph.index(e.tail)][graph.index(e.head)] = e.weight
  }
  0.upto(graph.size-1) { |k|
    0.upto(graph.size-1) { |i|
      0.upto(graph.size-1) { |j|
        if dist_matrix[i][k] + dist_matrix[k][j] < dist_matrix[i][j]
          dist_matrix  [i][j] = dist_matrix[i][k] + dist_matrix[k][j]
        end
      }
    }
  }
  return dist_matrix
end


# returns a list of nodes (graph) and a hash for finding
# nodes by their label (these need to be unique!)
def DAG::read_graph_from_json fn, semiring=RealSemiring.new
  graph = []
  nodes_by_label = {}
  h = JSON.parse File.new(fn).read
  h['nodes'].each { |i|
    n = DAG::Node.new i['label']
    graph << n
    nodes_by_label[n.label] = n
  }
  h['edges'].each { |i|
    n = nodes_by_label[i['tail']]
    a = n.add_edge(nodes_by_label[i['head']], semiring.convert.call(i['weight'].to_f))
    nodes_by_label[i['head']].incoming << a
  }
  return graph, nodes_by_label
end


end # module

