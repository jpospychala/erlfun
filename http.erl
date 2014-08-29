-module(http).
-export([start/2, start/0, listen/2, handle/2, read/1]).

start() -> start(8888, []).
start(Port, Middlewares) -> spawn(?MODULE, listen, [Port, Middlewares]).

listen(Port, Middlewares) ->
  case gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]) of
    {ok, LSock} -> loop(LSock, Middlewares);
    {error, Err} -> error_logger:warning_msg("stopped listen ~w", [Err]), stop
  end.

loop(LSock, Middlewares) ->
  case gen_tcp:accept(LSock) of
    {ok, S} -> spawn(?MODULE, handle, [S, Middlewares]);
    _ -> undefined
  end,
  loop(LSock, Middlewares).

handle(Socket, Middlewares) ->
  {ok, ReqBinary} = recv(Socket, <<"">>),
  Request = read(binary_to_list(ReqBinary)),
  Response = process(Request, Middlewares),
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
    "OPTIONS" -> post;
    "GET" -> get;
    "HEAD" -> head;
    "POST" -> post;
    "PUT" -> post;
    "DELETE" -> post;
    "TRACE" -> trace;
    "CONNECT" -> connect;
    _ -> error
  end,
  {Url, R2} = http_utils:token(R1),
  {T2, _} = http_utils:token(R2),
  HttpVer = case string:to_upper(T2) of
    "HTTP/1.0" -> http_10;
    "HTTP/1.1" -> http_11;
    _ -> error
  end,
  {M, Url, HttpVer}.


process({Method, Url, _}, Middlewares) ->
  RespFn = matchMiddleware(Method, Url, Middlewares),
  {_, Resp} = RespFn(),
  RespLen = string:len(Resp),
  "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: " ++ integer_to_list(RespLen) ++ "\r\n\r\n" ++ Resp.

matchMiddleware(M, U, [{M1,U1,Fn}|T]) ->
  if
    (((M1 == any) or (M == M1)) and ((U1 == any) or (U == U1))) -> Fn;
    T == [] -> fun() -> {404, "Not Found"} end;
    true-> matchMiddleware(M, U, T)
  end.

send(Socket, Response) ->
  gen_tcp:send(Socket, Response).
