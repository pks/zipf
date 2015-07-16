#!/usr/bin/env ruby

require_relative '../lib/zipf/SparseVector'
require 'test/unit'

class TestSparseVector <  Test::Unit::TestCase

  def test_unit
    v = SparseVector.new
    v[:a] = 1
    v[:b] = 2
    v[:c] = 3
    w = SparseVector.new v
    assert_equal Math.sqrt(1**2+2**2+3**2), v.norm
    v.unit!
    assert_equal v.norm, 1.0
    q = w.unit
    assert_equal q.norm, 1.0
    assert_equal w.norm, Math.sqrt(1**2+2**2+3**2)
  end
end

