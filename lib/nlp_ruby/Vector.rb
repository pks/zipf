class Vector < Array

  def sum
    self.inject(:+)
  end

  def average
    self.sum/self.size.to_f
  end

  def variance
    avg = self.average
    var = 0.0
    self.each { |i| var += (avg - i)**2 }
    var
  end

  def stddev list_of_values, decimal_places=-1
    Math.sqrt self.variance
  end

  def dot other
    return nil if self.size!=other.size
    sum = 0.0
    self.each_with_index { |i,j| sum += i*other[j] }
    return sum
  end

  def magnitude
     Math.sqrt self.inject { |sum,i| sum+i**2 }
  end

  def cosinus_sim other
    return self.dot(other)/(self.mag*other.mag)
  end

  def euclidian_dist other
    sum = 0.0
    self.each_with_index { |i,j| sum += (i - other[j])**2 }
    return Math.sqrt(sum)
  end
end

