version := $$(grep s.version nlp_ruby.gemspec | awk '{print $$3}' | sed "s|'||g")


all: lib/nlp_ruby.rb lib/nlp_ruby/bleu.rb lib/nlp_ruby/dag.rb lib/nlp_ruby/fileutil.rb lib/nlp_ruby/misc.rb lib/nlp_ruby/semirings.rb lib/nlp_ruby/SparseVector.rb lib/nlp_ruby/stringutil.rb lib/nlp_ruby/tfidf.rb lib/nlp_ruby/Translation.rb
	gem build nlp_ruby.gemspec

install:
	gem install nlp_ruby-$(version).gem

clean:
	rm nlp_ruby-$(version).gem
	gem uninstall nlp_ruby -v $(version)

rake_test:
	rake test

publish:
	gem push nlp_ruby-$(version).gem

