module BLEU


class BLEU::NgramCounts
  attr_accessor :sum, :clipped, :ref_len, :hyp_len, :n

  def initialize(n)
    @n = 0
    @sum = []
    @clipped = []
    @ref_len = 0.0
    @hyp_len = 0.0
    grow(n)
  end

  def grow(n)
    (n-@n).times {
      @sum << 0.0
      @clipped << 0.0
    }
    @n = n
  end

  def plus_eq(other)
    if other.n > @n then grow(other.n) end
    0.upto(other.n-1) { |m|
      @sum[m] += other.sum[m]
      @clipped[m] += other.clipped[m]
    }
    @ref_len += other.ref_len
    @hyp_len += other.hyp_len
  end

  def to_s
    return "n=#{n} sum=#{sum} clipped=#{clipped} ref_len=#{ref_len} hyp_len=#{hyp_len}"
  end
end

class BLEU::Ngrams
  def initialize
    @h_ = {}
    @h_.default = 0
  end

  def add(k)
    if k.class == Array then k = k.join ' ' end
    @h_[k] += 1
  end

  def get_count(k)
    if k.class == Array then k = k.join ' ' end
    return @h_[k]
  end

  def each
    @h_.each_pair { |k,v|
      yield k.split, v
    }
  end

  def to_s
    @h_.to_s
  end
end

def BLEU::get_counts hypothesis, reference, n, times=1
  p = NgramCounts.new n
  r = Ngrams.new
  ngrams(reference, n) { |ng| r.add ng }
  h = Ngrams.new
  ngrams(hypothesis, n) { |ng| h.add ng }
  h.each { |ng,count|
    sz = ng.size-1
    p.sum[sz] += count * times
    p.clipped[sz] += [r.get_count(ng), count].min * times
  }
  p.ref_len = tokenize(reference.strip).size * times
  p.hyp_len = tokenize(hypothesis.strip).size * times
  return p
end

def BLEU::brevity_penalty c, r
  return 1.0 if c>r
  return Math.exp(1-r/c)
end

def BLEU::bleu counts, n, debug=false
  corpus_stats = NgramCounts.new n
  counts.each { |i| corpus_stats.plus_eq i }
  sum = 0.0
  w = 1.0/n
  0.upto(n-1) { |m|
    STDERR.write "#{m+1} #{corpus_stats.clipped[m]} / #{corpus_stats.sum[m]}\n" if debug
    return 0.0 if corpus_stats.clipped[m] == 0 or corpus_stats.sum == 0
    sum += w * Math.log(corpus_stats.clipped[m] / corpus_stats.sum[m])
  }
  if debug
    STDERR.write "BP #{brevity_penalty(corpus_stats.hyp_len, corpus_stats.ref_len)}\n"
    STDERR.write "sum #{Math.exp(sum)}\n"
  end
  return brevity_penalty(corpus_stats.hyp_len, corpus_stats.ref_len) * Math.exp(sum)
end

def BLEU::hbleu counts, n, debug=false
  (100*bleu(counts, n, debug)).round(3)
end

def BLEU::per_sentence_bleu hypothesis, reference, n=4
  h_ng = {}; r_ng = {}
  (1).upto(n) {|i| h_ng[i] = []; r_ng[i] = []}
  ngrams(hypothesis, n) {|i| h_ng[i.size] << i}
  ngrams(reference, n) {|i| r_ng[i.size] << i}
  m = [n, reference.split.size].min
  weight = 1.0/m
  add = 0.0
  sum = 0
  (1).upto(m) { |i|
    counts_clipped = 0
    counts_sum = h_ng[i].size
    h_ng[i].uniq.each {|j| counts_clipped += r_ng[i].count(j)}
    add = 1.0 if i >= 2
    sum += weight * Math.log((counts_clipped + add)/(counts_sum + add));
  } 
  return brevity_penalty(hypothesis.strip.split.size, reference.strip.split.size) * Math.exp(sum)
end


end

