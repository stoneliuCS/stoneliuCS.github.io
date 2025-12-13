all: start

start:
	cd src && raco pollen start

reset:
	cd src && raco pollen reset

clean:
	rm -rf build && \
	find . \( -name "*.html" -o -name "*.css" \) -type f -print0 | xargs -0 /bin/rm -f

open:
	cd build/ && open index.html

publish:
	 mkdir build && raco pollen render src && raco pollen publish src build

create: clean publish open
