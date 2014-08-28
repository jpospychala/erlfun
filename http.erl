-module(http).
-export([start/1, start/0, listen/1, handle/1, read/1]).

start() -> start(8088).
start(Port) -> spawn(?MODULE, listen, [Port]).

listen(Port) ->
  case gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]) of
    {ok, LSock} -> loop(LSock);
    {error, Err} -> error_logger:warning_msg("stopped listen ~w", [Err]), stop
  end.

loop(LSock) ->
  case gen_tcp:accept(LSock) of
    {ok, S} -> spawn(?MODULE, handle, [S]);
    _ -> undefined
  end,
  loop(LSock).

handle(Socket) ->
  {ok, ReqBinary} = recv(Socket, []),
  Request = read(ReqBinary),
  Response = process(Request, {}),
  send(Socket, Response),
  gen_tcp:close(Socket).

recv(Socket, Bs) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, B} -> recv(Socket, [Bs, B]);
    {error, einval} -> {ok, list_to_binary(Bs)};
    {error, closed} -> {ok, list_to_binary(Bs)}
  end.

read(Req) -> read(http_utils:token(Req), method, {}).
read({"GET", Req}, method, {}) -> read(http_utils:token(Req), url, {get});
read({"POST", Req}, method, {}) -> read(http_utils:token(Req), url, {post});
read({Url, Req}, url, {Method}) -> read(http_utils:token(Req), httpVer, {Method, Url});
read({"HTTP/1.0", Req}, httpVer, {Method, Url}) -> {Method, Url, http_10};
read({"HTTP/1.1", Req}, httpVer, {Method, Url}) -> {Method, Url, http_11}.


process(Request, Response) -> {}.
send(Socket, Response) -> {}.
