Minimal Http server written in Erlang
=====================================

Following simple Http server returns 6 at "/sum?a=1&b=5"
```
-module(sample_app).
  -export([main/0]).

  main() ->
    http:start(8888, [
      {get, "/", fun(_) ->
        {200, "Hello World"}
      end},

      {get, "/sum", fun({[{"a", A}, {"b", B}]}) ->
        {200, str(int(A) + int(B))}
      end}
    ]).

  int(V) -> list_to_integer(V).
  str(V) -> integer_to_list(V).

```

Http server development
-----------------------

Run tests:

```make test```

Run server on default port 8888

```make run```
