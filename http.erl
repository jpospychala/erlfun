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
  Request = read(binary_to_list(ReqBinary)),
  Response = process(Request, {}),
  send(Socket, Response),
  gen_tcp:close(Socket).

recv(Socket, Bs) ->
  S = binary:match(list_to_binary(Bs), list_to_binary([13,10,13,10])),
  if not (S == nomatch) -> {ok, list_to_binary(Bs)};
    S == nomatch ->
    case gen_tcp:recv(Socket, 0) of
      {ok, B} -> recv(Socket, [Bs, B]);
      {error, einval} -> {ok, list_to_binary(Bs)};
      {error, closed} -> {ok, list_to_binary(Bs)}
    end
  end.

read(Req) ->
  M = case http_utils:token(Req) of
    {"GET", R2} -> get;
    {"POST", R2} -> post
  end,
  {Url, R3} = http_utils:token(R2),
  HttpVer = case http_utils:token(R3) of
    {"HTTP/1.0", R4} -> http_10;
    {"HTTP/1.1", R4} -> http_11
  end,
  {M, Url, HttpVer}.


process({_, Url, _}, Response) -> "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: 20\r\n\r\n<h1>hello world</h1>".
send(Socket, Response) ->
  gen_tcp:send(Socket, Response).
