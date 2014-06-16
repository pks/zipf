#!/usr/bin/env ruby

require 'nlp_ruby/stringutil'
require 'nlp_ruby/fileutil'
require 'nlp_ruby/SparseVector'
require 'nlp_ruby/tfidf'
require 'nlp_ruby/Translation'
require 'nlp_ruby/dag'
require 'nlp_ruby/semirings'
require 'nlp_ruby/bleu'
require 'nlp_ruby/misc'
require 'nlp_ruby/hg'
require 'nlp_ruby/grammar'

STDIN.set_encoding  'utf-8'
STDOUT.set_encoding 'utf-8'
STDERR.set_encoding 'utf-8'

