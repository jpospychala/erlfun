-module(http_test).
-include_lib("eunit/include/eunit.hrl").

should_read_http_request_test() ->
  {get,"/", http_10} = http:read("GET / HTTP/1.0\n\n").

should_read_http_request2_test() ->
  {post,"/hello", http_11} = http:read("POST /hello HTTP/1.1\n\n").

read_query_string_test() ->
  [{"a", "b"}] = http_utils:query_string("?a=b"),
  [{"a", "b"}] = http_utils:query_string("a=b").

% TODO
% switch http_utils to process binary rather than string
% process request headers
% generate response headers
% limit request line length to rfc limit
% make error handling erlang-like
