module Grammar


class T
  attr_accessor :word

  def initialize word
    @word = word
  end

  def to_s
    "T<#{@word}>"
  end
end

class NT
  attr_accessor :symbol, :index, :span

  def initialize symbol, index=0
    @symbol = symbol
    @index = index
    @span = Span.new
  end

  def to_s
    "NT(#{@span.left},#{@span.right})<#{@symbol},#{@index}>"
  end
end

class Rule
  attr_accessor :lhs, :rhs, :e

  def initialize lhs=nil, rhs=[], e=''
    @lhs = lhs
    @rhs = rhs
    @e = e
  end

  def to_s
    "#{lhs} -> #{rhs.map{ |i| i.to_s }.join ' '} [arity=#{arity}] ||| #{@e}"
  end

  def arity
    rhs.select { |i| i.class == NT }.size
  end

  def from_s s
    _ = splitpipe s, 3
    @lhs = NT.new _[0].strip.gsub!(/(\[|\])/, "")
    _[1].split.each { |x|
      x.strip!
      if x[0]=='[' && x[x.size-1] == ']'
        @rhs << NT.new(x.gsub!(/(\[|\])/, "").split(',')[0])
      else
        @rhs << T.new(x)
      end
    }
    @e = _[2]
  end

  def self.from_s s
    r = self.new
    r.from_s s
    return r
  end
end

class Span
  attr_accessor :left, :right

  def initialize left=nil, right=nil
    @left = left
    @right = right
  end
end

class Grammar
  attr_accessor :rules, :startn, :startt, :flat

  def initialize fn
    @rules = []; @startn = []; @startt = [] ;@flat = []
    ReadFile.readlines_strip(fn).each_with_index { |s,i|
      STDERR.write '.'; STDERR.write " #{i+1}\n" if (i+1)%80==0
      @rules << Rule.from_s(s)
      if @rules.last.rhs.first.class == NT
        @startn << @rules.last
      else
        if rules.last.arity == 0
          @flat << @rules.last
        else
          @startt << @rules.last
        end
      end
    }
    STDERR.write "\n"
  end

  def to_s
    s = ''
    @rules.each { |r| s += r.to_s+"\n" }
    return s
  end

  def add_glue_rules
    @rules.map { |r| r.lhs.symbol }.select { |s| s != 'S' }.uniq.each { |symbol|
      @rules << Rule.new(NT.new('S'), [NT.new(symbol)])
      @startn << @rules.last
      @rules << Rule.new(NT.new('S'), [NT.new('S'), NT.new('X')])
      @startn << @rules.last
    }
  end

  def add_pass_through_rules s
    s.each { |word|
      @rules << Rule.new(NT.new('X'), [T.new(word)])
      @flat << @rules.last
    }
  end
end


end #module

