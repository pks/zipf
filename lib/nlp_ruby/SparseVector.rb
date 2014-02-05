class SparseVector < Hash

  def initialize
    super
    self.default = 0
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

  def to_kv
    a = []
    self.each_pair { |k,v|
      a << "#{k}=#{v}"
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

