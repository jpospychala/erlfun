Minimal Http server written in Erlang
=====================================

Following simple Http server responds with "Hello World" on main page:
```
-module(myapp).
-export([main/0]).

main() ->
  http:start(8888, [
    {get, "/", fun() ->
      {200, "Hello World"}
    end},

    {any, any, fun() ->
      {404, "Not this time dude"}
    end}
  ]).
```

Http server development
-----------------------

Run tests:

```make test```

Run server on default port 8888

```make run```
