class Translation
  attr_accessor :id, :s, :raw, :f, :scores, :rank

  def initialize id=nil, raw=nil, s=nil, f=nil, scores={}, rank=nil
    @id = id
    @raw = raw
    @s = s
    @f = f
    @scores = scores
    @rank = rank
  end

  def from_s t, strip_alignment=true, rank=nil
    id, raw, features, score = splitpipe(t, 3)
    raw.strip!
    @raw = raw
    if strip_alignment # the way moses does it
      @s = @raw.gsub(/\s*\|\d+-\d+\||\|-?\d+\|\s*/, ' ').gsub(/\s+/, ' ')
      @s.strip!
    else
      @s = raw
    end
    @id = id.to_i
    @f = SparseVector.from_kv features
    @scores[:decoder] = score.to_f
    @rank = rank
  end

  def self.from_s s
    t = self.new
    t.from_s s
    return t
  end

  def to_s include_features=true
    [@id, @s, @f.to_kv('=', ' '), @scores[:decoder]].join(' ||| ') if include_features
    [@id, @s, @scores[:decoder]].join(' ||| ') if !include_features
  end

  def to_s2
    [@rank, @s, @score, @scores.to_s].join ' ||| '
  end
end

def read_kbest_lists fn, translation_type=Translation
  kbest_lists = []
  cur = []
  f = ReadFile.new fn
  prev = -1
  c = 0
  id = 0
  while line = f.gets
    t = translation_type.new
    t.from_s line
    c = splitpipe(line)[0].to_i
    if c != prev
      if cur.size > 0
        kbest_lists << cur
        cur = []
      end
      prev = c
      id = 0
    end
    t.id = id
    cur << t
    id += 1
  end
  kbest_lists << cur # last one
  f.close
  return kbest_lists
end

