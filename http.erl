-module(http).
-export([start/1, start/0, listen/1, handle/1, read/1]).

start() -> start(8888).
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
  {ok, ReqBinary} = recv(Socket, <<"">>),
  Request = read(binary_to_list(ReqBinary)),
  Response = process(Request, {}),
  send(Socket, Response),
  gen_tcp:close(Socket).

recv(Socket, Bs) ->
  S = binary:match(Bs, <<"\r\n\r\n">>),
  if not (S == nomatch) -> {ok, Bs};
    S == nomatch ->
    case gen_tcp:recv(Socket, 0) of
      {ok, B} -> recv(Socket, list_to_binary([Bs, B]));
      {error, einval} -> {ok, Bs};
      {error, closed} -> {ok, Bs}
    end
  end.

read(Req) ->
  {T1,R1} = http_utils:token(Req),
  M = case string:to_upper(T1) of
    "GET" -> get;
    "POST" -> post;
    _ -> error
  end,
  {Url, R2} = http_utils:token(R1),
  {T2, R3} = http_utils:token(R2),
  HttpVer = case string:to_upper(T2) of
    "HTTP/1.0" -> http_10;
    "HTTP/1.1" -> http_11;
    _ -> error
  end,
  {M, Url, HttpVer}.


process({_, Url, _}, Response) ->
  Resp = "<h1>hello " ++ Url ++ "</h1>",
  RespLen = string:len(Resp),
  "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: " ++ integer_to_list(RespLen) ++ "\r\n\r\n" ++ Resp.

send(Socket, Response) ->
  gen_tcp:send(Socket, Response).
