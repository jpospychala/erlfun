all: build test run

build:
	erlc http_utils.erl http.erl http_test.erl

test: build
	erl -noshell -s http_test test -s init stop

sample_app_build:
	erlc sample_app.erl integration_test.erl

sample_app_test: sample_app_build
	erl -noshell -s integration_test test -s init stop

run_sample: sample_app_build sample_app_test
	erl -noshell -s sample_app main
