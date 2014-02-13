class SparseVector < Hash

  def initialize arg=nil
    super
    self.default = 0
    if arg.is_a? Array
      from_a arg
    end
  end

  def from_a a
    a.each_with_index { |i,j| self[j] = i }
  end

  def from_h h
    h.each_pair { |k,v| self[k] = v }
  end

  def from_s s
    from_h eval(s)
  end

  def sum
    self.values.inject(:+)
  end

  def approx_eql? other, p=10**-10
    return false if !other
    return false if other.size!=self.size
    return false if other.keys.sort!=self.keys.sort
    self.keys.each { |k|
      return false if (self[k]-other[k]).abs>p
    }
    return true
  end

  def average
    self.sum/self.size.to_f
  end

  def variance
    avg = self.average
    var = 0.0
    self.values.each { |i| var += (avg - i)**2 }
    return var
  end

  def stddev
    Math.sqrt self.variance
  end

  def dot other
    sum = 0.0
    self.each_pair { |k,v| sum += v * other[k] }
    return sum
  end

  def zeros n
    (0).upto(n-1) { |i| self[i] = 0.0 }
  end

  def magnitude
    Math.sqrt self.values.inject { |sum,i| sum+i**2 }
  end

  def cosinus_sim other
    self.dot(other)/(self.magnitude*other.magnitude)
  end

  def euclidian_dist other
    dims = [self.keys, other.keys].flatten.uniq
    sum = 0.0
    dims.each { |d| sum += (self[d] - other[d])**2 }
    return Math.sqrt(sum)
  end

  # FIXME
  def from_kv_file fn, sep=' '
    f = ReadFile.new(fn)
    while line = f.gets
      key, value = line.strip.split sep
      value = value.to_f
      self[key] = value
    end
  end
  
  # FIXME
  def to_kv sep='='
    a = []
    self.each_pair { |k,v|
      a << "#{k}#{sep}#{v}"
    }
    return a.join ' '
  end

  def join_keys other
    self.keys + other.keys
  end

  def + other
    new = SparseVector.new
    join_keys(other).each { |k|
      new[k] = self[k]+other[k]
    }
    return new
  end

  def - other
    new = SparseVector.new
    join_keys(other).each { |k|
      new[k] = self[k]-other[k]
    }
    return new
  end

  def * scalar
    raise ArgumentError, "Arg is not numeric #{scalar}" unless scalar.is_a? Numeric
    new = SparseVector.new
    self.keys.each { |k|
      new[k] = self[k] * scalar
    }
    return new
  end
end

def mean_sparse_vector array_of_vectors
  mean = SparseVector.new
  array_of_vectors.each { |i|
    i.each_pair { |k,v|
      mean[k] += v
    }
  }
  n = array_of_vectors.size.to_f
  mean.each_pair { |k,v| mean[k] = v/n }
  return mean
end

