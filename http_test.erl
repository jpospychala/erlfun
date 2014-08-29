-module(http_test).
-include_lib("eunit/include/eunit.hrl").

should_read_http_request_test() ->
  {get,"/", http_10} = http:read("GET / HTTP/1.0\n\n").

should_read_http_request2_test() ->
  {post,"/hello", http_11} = http:read("POST /hello HTTP/1.1\n\n").


% TODO
% switch http_utils to process binary rather than string
% should parse URI and use only path part when dispatching to middleware (not query)
% process request headers
% generate response headers
