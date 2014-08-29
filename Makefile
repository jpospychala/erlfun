all: build test run

build:
	erlc http_utils.erl http.erl http_test.erl

test: build
	erl -noshell -s http_test test -s init stop

run_sample: build test
	erlc sample_app.erl
	erl -noshell -s sample_app main
