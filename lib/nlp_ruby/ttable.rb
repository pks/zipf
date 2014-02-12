# table['some French string'] = [Array of English strings]
def read_phrase_table fn
  table = {}
  f = ReadFile.new fn
  while raw_rule = f.gets
    french, english, features = splitpipe(raw_rule)
    feature_map = read_feature_string(features)
    if table.has_key? french
      table[french] << [english, feature_map ]
    else
      table[french] = [[english, feature_map]]
    end
  end
  f.close
  return table
end

# FIXME
class Translation
  attr_accessor :id, :s, :raw, :f, :score, :rank, :other_score

  def initialize id=nil, raw=nil, s=nil, f=nil, score=nil, rank=nil, other_score=nil
    @id = id
    @raw = raw
    @s = s
    @f = f
    @score = score
    @rank = rank
    @other_score = other_score
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
    @f = read_feature_string features
    @score = score.to_f
    @rank = rank
    @other_score = nil
  end

  def to_s
    [@id, @s, @f.to_kv, @score].join ' ||| '
  end

  def to_s2
    [@rank, @s, @f.to_kv, @score, @other_score].join ' ||| '
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

