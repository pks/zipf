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

def BLEU::best_match_length hypothesis, references
  hyp_len = hypothesis.strip.split.size 
  ref_lens = references.map { |r| r.strip.split.size }
  min = Integer::MAX
  min_idx = -1
  ref_lens.each_with_index { |l,i|
    min_idx = i if (hyp_len-l).abs < min
  }
  return hyp_len, ref_lens[min_idx]
end

def BLEU::get_counts hypothesis, references, n, times=1
  p = NgramCounts.new n
  r = []
  references.each { |reference|
    r << Ngrams.new
    ngrams(reference, n) { |ng| r.last.add ng }
  }
  h = Ngrams.new
  ngrams(hypothesis, n) { |ng| h.add ng }
  h.each { |ng,count|
    sz = ng.size-1
    p.sum[sz] += count * times
    p.clipped[sz] += [r.map { |i| i.get_count(ng)}.max, count].min * times
  }
  p.hyp_len, p.ref_len = best_match_length hypothesis, references
  p.hyp_len *= times
  p.ref_len *= times
  return p
end

def BLEU::brevity_penalty c, r, smooth=0.0
  return [0.0, 1.0-((r+smooth)/c)].min
end

def BLEU::bleu_ counts, n, debug=false
  corpus_stats = NgramCounts.new n
  counts.each { |i| corpus_stats.plus_eq i }
  logbleu = 0.0
  0.upto(n-1) { |m|
    STDERR.write "#{m+1} #{corpus_stats.clipped[m]} / #{corpus_stats.sum[m]} = #{(corpus_stats.clipped[m]/corpus_stats.sum[m]).round 2}\n" if debug
    return 0.0 if corpus_stats.clipped[m] == 0 or corpus_stats.sum == 0
    logbleu += Math.log(corpus_stats.clipped[m]) - Math.log(corpus_stats.sum[m])
  }
  logbleu /= n
  STDERR.write "BP #{brevity_penalty(corpus_stats.hyp_len, corpus_stats.ref_len).round 2}\n" if debug
  logbleu += brevity_penalty corpus_stats.hyp_len, corpus_stats.ref_len
  return Math.exp logbleu
end

def BLEU::bleu hyp_file, ref_file, n, debug=false
  hypotheses = ReadFile.readlines_strip(hyp_file)
  references = ReadFile.readlines_strip(ref_file).map { |l|
    splitpipe(l,3)
  }
  counts = []
  hypotheses.each_with_index { |h,i|
    counts << BLEU::get_counts(h, references[i], 4)
  }
  bleu_ counts, n, debug
end

def BLEU::hbleu_ counts, n, debug=false
  (100*bleu(counts, n, debug)).round(3)
end

def BLEU::hbleu hypotheses, references, n, debug=false
end

def BLEU::per_sentence_bleu hypothesis, references, n=4, smooth=0.0
  h_ng = {}; r_ng = []
  num_ref = references.size
  num_ref.times { r_ng << {} }
  (1).upto(n) { |i| h_ng[i] = []; num_ref.times { |j| r_ng[j][i] = [] } }
  ngrams(hypothesis, n) { |i| h_ng[i.size] << i }
  references.each_with_index { |reference,j|
    ngrams(reference, n) { |i| r_ng[j][i.size] << i }
  }
  m = [n, references.map { |i| i.split.size }.max].min
  add = 0.0
  logbleu = 0.0
  (1).upto(m) { |i|
    counts_clipped = 0
    counts_sum = h_ng[i].size
    h_ng[i].uniq.each { |j|
      max_count = [h_ng[i].count(j), r_ng.map { |r| r[i].count(j) }.max].min
      counts_clipped += max_count 
    }
    add = 1.0 if i >= 2
    logbleu += Math.log(counts_clipped+add) - Math.log(counts_sum+add);
  }
  logbleu /= m
  hyp_len, best_ref_len = BLEU::best_match_length hypothesis, references
  logbleu += brevity_penalty hyp_len, best_ref_len, smooth
  return Math.exp logbleu
end

end #module

