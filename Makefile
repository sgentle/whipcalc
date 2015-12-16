.PHONY: all build watch browserify

all: build

build:
	NODE_ENV=production node_modules/.bin/webpack

watch:
	node_modules/.bin/webpack --watch

browserify:
	pulp browserify -O | uglifyjs > public/app.js
