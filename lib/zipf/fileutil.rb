require 'zlib'

class ReadFile

  def initialize fn, encoding='utf-8'
    if fn.split('.').last == 'gz'
      @f = Zlib::GzipReader.new(File.new(fn, 'rb'), :external_encoding=>encoding)
    elsif fn == '-'
      @f = STDIN
      STDIN.set_encoding encoding
    else
      @f = File.new fn, 'r'
      @f.set_encoding encoding
    end
  end

  def gets
    @f.gets { |line| yield line }
  end

  def readlines
    @f.readlines
  end

  def self.readlines fn, encoding='utf-8'
    f = ReadFile.new fn, encoding
    r = f.readlines
    f.close
    return r
  end

  def readlines_strip
    self.readlines.map{ |i| i.strip }
  end

  def self.readlines_strip fn, encoding='utf-8'
    f = ReadFile.new fn, encoding
    r = f.readlines_strip
    f.close
    return r
  end

  def read
    @f.read
  end

  def self.read fn, encoding='utf-8'
    f = ReadFile.new fn, encoding
    r = f.read
    f.close
    return r
  end

  def close
    @f.close if @f!=STDIN
  end
end

class WriteFile

  def initialize fn, encoding='utf-8'
    if fn.split('.').last == 'gz'
      @f = Zlib::GzipWriter.new(File.new(fn, 'wb+'), :external_encoding=>encoding)
    elsif fn == '-'
      @f = STDOUT
      STDOUT.set_encoding encoding
    else
      @f = File.new fn, 'w+'
      @f.set_encoding encoding
    end
  end

  def write s
    @f.write s
  end

  def self.write s, fn, encoding='utf-8'
    f = WriteFile.new fn, encoding
    f.write s
    f.close
  end

  def close
    @f.close if @f!=STDIN
  end
end

