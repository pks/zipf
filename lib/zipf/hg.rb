#!/usr/bin/env ruby

require_relative 'semirings'
require 'json'


module HG


class HG::Node
  attr_accessor :label, :cat, :outgoing, :incoming, :score

  def initialize label=nil, cat=nil, outgoing=[], incoming=[], score=nil
    @label    = label
    @cat      = cat
    @outgoing = outgoing
    @incoming = incoming
    @score    = nil
  end

  def to_s
    "Node<label:\"#{@label}\", cat:\"#{@cat}\", outgoing:#{@outgoing.size}, incoming:#{@incoming.size}>"
  end
end

class HG::Hypergraph
  attr_accessor :nodes, :edges

  def initialize nodes=[], edges=[]
    @nodes = nodes
    @edges = edges
  end

  def arity
    @edges.map { |e| e.arity }.max
  end

  def to_s
    "Hypergraph<nodes:[#{@nodes.to_s}], edges:[#{@edges.to_s}], arity:#{arity}>"
  end
end

class HG::Hyperedge
  attr_accessor :head, :tails, :weight, :f, :mark, :rule, :left, :right

  def initialize head=nil, tails=[], weight=0.0, f={}
    @head   = head
    @tails  = tails
    @weight = weight
    @f      = f
    @mark   = 0
  end

  def arity
    return @tails.size
  end

  def marked?
    arity == @mark
  end

  def to_s
    "Hyperedge<head:\"#{@head.label}\", \"tails:#{@tails.map{|n|n.label}}, arity:#{arity}, weight:#{@weight}, f:#{f.to_s}, mark:#{@mark}>"
  end
end

def HG::topological_sort nodes
  sorted = []
  s = nodes.reject { |n| !n.incoming.empty? }
  while !s.empty?
    sorted << s.shift
    sorted.last.outgoing.each { |e|
      next if e.marked?
      e.mark += 1
      s << e.head if e.head.incoming.reject{ |f| f.mark==f.arity }.empty?
    }
  end
  return sorted
end

def HG::init nodes, semiring, root
  nodes.each { |n| n.score=semiring.null }
  root.score = semiring.one
end

def HG::viterbi hypergraph, root, semiring=ViterbiSemiring.new
  toposorted = topological_sort hypergraph.nodes
  init toposorted, semiring, root
  toposorted.each { |n|
    n.incoming.each { |e|
      s = semiring.one
      e.tails.each { |m|
        s = semiring.multiply.call(s, m.score)
      }
      n.score = semiring.add.call(n.score, semiring.multiply.call(s, e.weight))
    }
  }
end

def HG::viterbi_path hypergraph, root, semiring=ViterbiSemiring.new
  toposorted = topological_sort hypergraph.nodes
  init toposorted, semiring, root
  best_path = []
  toposorted.each { |n|
    best_edge = nil
    n.incoming.each { |e|
      s = semiring.one
      e.tails.each { |m|
        s = semiring.multiply.call(s, m.score)
      }
      if n.score < semiring.multiply.call(s, e.weight) # ViterbiSemiring add
        best_edge = e
      end
      n.score = semiring.add.call(n.score, semiring.multiply.call(s, e.weight))
    }
    best_path << best_edge
  }
  return best_path, toposorted.last.score
end

def HG::read_hypergraph_from_json fn, semiring=RealSemiring.new, log_weights=false
  nodes = []
  edges = []
  nodes_by_label = {}
  nodes_by_index = []
  h = JSON.parse File.new(fn).read
  w = SparseVector.from_h h['weights']
  h['nodes'].each { |i|
    n = Node.new i['label'], i['cat']
    nodes << n
    nodes_by_label[n.label] = n
    nodes_by_index << n
  }
  h['edges'].each { |i|
    e = Hyperedge.new(nodes_by_label[i['head']], \
                      i['tails'].map{|j| nodes_by_label[j]}.to_a, \
                      semiring.convert.call(i['weight'].to_f), \
                      {})
    e.f = SparseVector.from_h i['f']
    if log_weights
      e.weight = Math.exp(w.dot(e.f))
    else
      e.weight = w.dot(e.f)
    end
    e.tails.each { |m|
      m.outgoing << e
    }
    e.head.incoming << e
    edges << e
  }
  return Hypergraph.new(nodes, edges), nodes_by_label, nodes_by_index
end

def HG::all_paths hypergraph, root, semiring=ViterbiSemiring.new
  toposorted = topological_sort hypergraph.nodes
  paths = [[]]
  toposorted.each { |n|
    next if n.incoming.empty?
    new_paths = []
    while !paths.empty?
      p = paths.pop
      n.incoming.each { |e|
        new_paths << p+[e]
      }
    end
    paths = new_paths
  }
  return paths
end


end #module

