#!/usr/bin/env ruby

require_relative '../lib/zipf'
require 'test/unit'


class TestHG <  Test::Unit::TestCase

  def test_viterbi
    semiring = ViterbiSemiring.new
    hypergraph, nodes_by_label, nodes_by_index = HG::read_hypergraph_from_json('test/hg/hg.json', semiring, true)
    HG::viterbi hypergraph, nodes_by_label['root'], semiring
    assert_equal('Goal', nodes_by_index.last.cat)
    assert_equal(228.95, Math.log(nodes_by_index.last.score).round(2))
    # do all operations in log space
    semiring = ViterbiLogSemiring.new
    hypergraph, nodes_by_label, nodes_by_index = HG::read_hypergraph_from_json('test/hg/hg.json', semiring)
    HG::viterbi hypergraph, nodes_by_label['root'], semiring
    assert_equal('Goal', nodes_by_index.last.cat)
    assert_equal(228.95, nodes_by_index.last.score.round(2))
    assert_equal hypergraph.nodes.size, 221
    assert_equal hypergraph.edges.size, 16640
  end
end

