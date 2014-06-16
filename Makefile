version := $$(grep s.version zipf.gemspec | awk '{print $$3}' | sed "s|'||g")


all: lib/zipf.rb lib/zipf/bleu.rb lib/zipf/dag.rb lib/zipf/fileutil.rb lib/zipf/misc.rb lib/zipf/semirings.rb lib/zipf/SparseVector.rb lib/zipf/stringutil.rb lib/zipf/tfidf.rb lib/zipf/Translation.rb
	gem build zipf.gemspec

install:
	gem install zipf-$(version).gem

clean:
	rm zipf-$(version).gem
	gem uninstall zipf -v $(version)

rake_test:
	rake test

publish:
	gem push zipf-$(version).gem

