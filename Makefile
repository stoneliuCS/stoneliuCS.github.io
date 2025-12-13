all: serve 

build:
	cd src && jekyll build

serve:
	cd src && bundle install && jekyll serve
