module TFIDF


# returns key='raw frequency' for an
# array-like object
def TFIDF::tf array, stopwords=[]
  v = {}; v.default = 0
  array.uniq.each { |i|
   next if stopwords.include? i
   v[i] = array.count(i).to_f
  }
  return v
end

# smoothes raw frequencies of tf() in-place
# a is a smoothing term
def TFIDF::ntf hash, a=0.4
  max = hash.values.max.to_f
  hash.each_pair { |k,v|
    hash[k] = a + (1-a)*(v/max)
  }
end

# returns idf value for each word in a vocabulary
def TFIDF::idf list_of_hashes
  vocab = list_of_hashes.values.flatten.uniq
  n = list_of_hashes.size.to_f
  idf = {}
  vocab.each { |i|
    df = list_of_hashes.values.flatten.count i
    idf[i] = Math.log(n/df)
  }
  return idf
end


end #module

