# whitespace 'tokenizer'
def tokenize s
  s.strip.split
end

def splitpipe s, n=3
  s.strip.split("|"*n)
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


def read_cfg fn
  f = ReadFile.new fn
  cfg = {}
  while line = f.gets
    line.strip!
    next if /^\s*$/.match line
    next if line[0]=='#'
    content = line.split('#', 2).first
    k, v = content.split(/\s*=\s*/, 2)
    k.strip!; v.strip!
    cfg[k] = v
  end
  return cfg
end

