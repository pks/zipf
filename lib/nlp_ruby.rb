#!/usr/bin/env ruby

require 'nlp_ruby/stringutil'
require 'nlp_ruby/fileutil'
require 'nlp_ruby/Vector'
require 'nlp_ruby/SparseVector'
require 'nlp_ruby/PriorityQueue'
require 'nlp_ruby/tfidf'
require 'nlp_ruby/ttable'
require 'nlp_ruby/dags'
require 'nlp_ruby/semirings'
require 'nlp_ruby/bleu'
require 'nlp_ruby/misc'
require 'nlp_ruby/cdec'

STDIN.set_encoding 'utf-8'
STDOUT.set_encoding 'utf-8'
STDERR.set_encoding 'utf-8'

