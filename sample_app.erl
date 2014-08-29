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
