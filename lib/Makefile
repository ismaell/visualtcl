all: TAGS

TAGS: *.tcl ../*.tcl
	etags --regex='/proc[ \t]+\([^ \t]+\)/\1/' *.tcl ../*.tcl
clean::
	rm -f TAGS
