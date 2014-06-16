#!/usr/bin/env ruby

require 'zipf/stringutil'
require 'zipf/fileutil'
require 'zipf/SparseVector'
require 'zipf/tfidf'
require 'zipf/Translation'
require 'zipf/dag'
require 'zipf/semirings'
require 'zipf/bleu'
require 'zipf/misc'
require 'zipf/hg'
require 'zipf/grammar'

STDIN.set_encoding  'utf-8'
STDOUT.set_encoding 'utf-8'
STDERR.set_encoding 'utf-8'

