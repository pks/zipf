#!/usr/bin/env ruby

require 'zipf/bleu'
require 'zipf/dag'
require 'zipf/fileutil'
require 'zipf/hypergraph'
require 'zipf/misc'
require 'zipf/semirings'
require 'zipf/SparseVector'
require 'zipf/stringutil'
require 'zipf/tfidf'
require 'zipf/Translation'

STDIN.set_encoding  'utf-8'
STDOUT.set_encoding 'utf-8'
STDERR.set_encoding 'utf-8'

