.PHONY: html css js all

all: html css js

html:
	jade index.jade

css:
	sass --update stylesheets

js:
	coffee --map --output javascripts --compile coffeescripts
