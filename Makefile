all: serve

build:
	python3 build.py

serve: build
	cd _site && python3 -m http.server 8000

open: build
	@(sleep 1 && open http://localhost:8000) &
	cd _site && python3 -m http.server 8000

dev:
	@(sleep 1 && open http://localhost:8000) &
	python3 serve.py

.PHONY: all build serve open dev
