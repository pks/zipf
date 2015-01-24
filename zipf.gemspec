Gem::Specification.new do |s|
  s.name        = 'zipf'
  s.version     = '1.2'
  s.date        = '2015-01-21'
  s.summary     = 'zipf'
  s.description = 'NLP related tools and classes'
  s.authors     = ['Patrick Simianer']
  s.email       = 'p@simianer.de'
  s.files       = Dir['lib/*.rb', 'lib/zipf/*.rb']
  s.homepage    = 'http://simianer.de'
  s.license     = 'MIT'
  s.add_runtime_dependency 'json',['>=0']
end

