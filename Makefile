version := $$(grep s.version nlp_ruby.gemspec | awk '{print $$3}' | sed "s|'||g")


all:
	gem build nlp_ruby.gemspec

install:
	gem install nlp_ruby-$(version).gem

clean:
	gem uninstall nlp_ruby -v $(version)

