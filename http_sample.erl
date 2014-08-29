-module(http_sample).
-export([example1/0]).

example1() ->
  http:start(8888, [
    {get, "/", fun() ->
      {200, "Hello World"}
    end},

    {any, any, fun() ->
      {404, "Not this time dude"}
    end}
  ]).
