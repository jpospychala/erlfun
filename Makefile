all: build test run

build:
	erlc http_utils.erl http.erl http_test.erl

test: build
	erl -noshell -s http_test test -s init stop

run: build
	erl -noshell -s http start
