def tokenize s
  s.strip.split
end

def ngrams(s, n, fix=false)
  a = tokenize s
  a.each_with_index { |tok, i|
    tok.strip!
    0.upto([n-1, a.size-i-1].min) { |m|
      yield a[i..i+m] if !fix||(fix&&a[i..i+m].size==n)
    }
  }
end

def bag_of_words s, stopwords=[]
  s.strip.split.uniq.sort.reject{ |w| stopwords.include? w }
end

def splitpipe s, n=3
  s.strip.split("|"*n)
end

