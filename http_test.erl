-module(http_test).
-export([suite/0]).

suite() ->
  should_read_http_request(),
  ok.

should_read_http_request() ->
  {get,"/", http_10} = http:read("GET / HTTP/1.0\n\n").

fail(Reason) -> {error, Reason}.
