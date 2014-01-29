# whitespace 'tokenizer'
def tokenize s
  s.strip.split
end

def splitpipe s
  s.strip.split(/\s*\|\|\|\s*/)
end

def downcase? s
  s[/[[:lower:]]/]
end

# iterator over n-grams
def ngrams(s, n, fix=false)
  a = tokenize s
  a.each_with_index { |tok, i|
    tok.strip!
    0.upto([n-1, a.size-i-1].min) { |m|
      yield a[i..i+m] if !fix||(fix&&a[i..i+m].size==n)
    }
  }
end

# a=1.0 b=2.0 => { 'a' => 1.0, 'b' => 2.0 }
def read_feature_string s
  map = SparseVector.new
  tokenize(s).each { |i|
    key, value = i.split '='
    map[key] = value.to_f
  }
  return map
end

