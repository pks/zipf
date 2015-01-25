#!/usr/bin/env ruby

require_relative '../lib/zipf/bleu'
require_relative '../lib/zipf/stringutil'
require_relative '../lib/zipf/fileutil'
require_relative '../lib/zipf/misc'
require 'test/unit'

class TestBLEU <  Test::Unit::TestCase

  def test_raw
    h = ["a s d f x", "a s f d"]
    r = [["a s d f", "a s d f a", "a s d f x"], ["a s d f", "a s d f a", "a s d f x"]]
    counts = []
    h.each_with_index { |h,i|
      counts << BLEU::get_counts(h, r[i], 4)
    }
    BLEU::bleu_ counts, 4, true
  end

  def test
    BLEU::bleu 'test/bleu/h', 'test/bleu/r', 4, true
  end
end






