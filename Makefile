all: start

start:
	raco pollen start

clean:
	rm -rf *.html
	rm -rf compiled

