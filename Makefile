version := $$(grep s.version nlp_ruby.gemspec | awk '{print $$3}' | sed "s|'||g")


all:
	rm nlp_ruby-$(version).gem
	gem build nlp_ruby.gemspec

install:
	gem install nlp_ruby-$(version).gem

clean:
	gem uninstall nlp_ruby -v $(version)

rake_test:
	rake test

publish:
	gem push nlp_ruby-$(version).gem

