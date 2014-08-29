-module(http_test).
-include_lib("eunit/include/eunit.hrl").

should_read_http_request_test() ->
  {get,"/", http_10} = http:read("GET / HTTP/1.0\n\n").
