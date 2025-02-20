all: start

start:
	raco pollen start

reset:
	raco pollen reset

clean:
	rm -rf *.html
	rm -rf compiled
	rm -rf *.css

