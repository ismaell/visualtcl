all: TAGS

TAGS:
	etags --regex='/proc[ \t]+\([^ \t]+\)/\1/' *.tcl ../*.tcl
clean:
	rm -f TAGS
