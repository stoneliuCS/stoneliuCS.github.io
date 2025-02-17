FROM racket/racket:8.9-full AS build

COPY . /code/
WORKDIR /code 
RUN raco pkg install pollen

