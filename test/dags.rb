#!/usr/bin/env ruby

require 'nlp_ruby'
require 'test/unit'


class TestDAG <  Test::Unit::TestCase

  def test_viterbi
    semiring = ViterbiSemiring.new
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json', semiring)
    DAG::viterbi(graph, semiring, nodes_by_label['0'])
    assert_equal(nodes_by_label['100'].score, 0.003)
  end

  # no negative weights here!
  def test_dijkstra
    semiring = RealSemiring.new
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json', semiring)
    DAG::dijkstra(graph, semiring, nodes_by_label['0'])
    assert_equal(nodes_by_label['100'].score, 0.5)
  end

  def test_bellman_ford
    semiring = RealSemiring.new
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json', semiring)
    DAG::bellman_ford(graph, semiring, nodes_by_label['0'])
    assert_equal(nodes_by_label['100'].score, 0.5)
  end

  def test_floyd
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json')
    d = DAG::floyd(graph)
    assert_equal(d[0][graph.size-1], 0.5)
  end

  def test_dfs
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json')
    assert_equal(nodes_by_label['100'], DAG::dfs(nodes_by_label['0'], '100'))
  end

  def test_bfs
    graph, nodes_by_label = DAG::read_graph_from_json('dags/example.json')
    assert_equal(nodes_by_label['100'], DAG::bfs(nodes_by_label['0'], '100'))
  end
end

