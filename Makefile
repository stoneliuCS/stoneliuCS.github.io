all: start

start:
	raco pollen start

reset:
	raco pollen reset

clean:
	rm -rf build && \
	cd src/ && \
	rm -rf *.html compiled *.css \
	./blog/*.html ./blog/compiled ./blog/*.css \
	./scratchpad/*.html ./scratchpad/compiled ./scratchpad/*.css

open:
	cd build/ && open index.html

publish:
	 mkdir build && raco pollen render src && raco pollen publish src build

create: clean publish open

