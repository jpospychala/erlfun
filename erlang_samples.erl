-module(erlang_samples).
-export([client/3, match_hello/1, test_match_hello/0, word/1, word/2, test_word/0]).


% TCP CLIENT
client(PortNo,Host,Message) ->
    {ok,Sock} = gen_tcp:connect(Host,PortNo,[{active, false}, {packet, 0}]),
    gen_tcp:send(Sock, Message),
    {ok, Bin} = do_recv(Sock, []),
    ok = gen_tcp:close(Sock),
    Bin.

do_recv(Sock, Bs) ->
  case gen_tcp:recv(Sock, 0) of
    {ok, B} -> do_recv(Sock, [Bs, B]);
    {error, einval} -> {ok, list_to_binary(Bs)};
    {error, closed} -> {ok, list_to_binary(Bs)}
  end.


% PATTERN MATCHING STRING
match_hello("hello" ++ _) -> hello;
match_hello(_) -> error.

test_match_hello() ->
  hello = match_hello("hello Franek"),
  error = match_hello("goodbye Lucy"),
  ok.

% READ FIRST WORD FROM TEXT
word(Text) -> word(Text, " \t\r\n").
word(Text, Delims) -> word(Text, Delims, []).
word([], Delims, Acc) -> lists:reverse(Acc);
word([H|T], Delims, Acc) -> word(T, H, Delims, Acc, string:chr(Delims, H) == 0).
word(T, H, Delims, [], false) -> word(T, Delims, []);
word(T, H, Delims, Acc, false) -> lists:reverse(Acc);
word(T, H, Delims, Acc, _) -> word(T, Delims, [H|Acc]).

test_word() ->
  "koala" = word("koala walks"),
  "koala" = word(" koala walks"),
  "koala" = word("koala"),
  "koala" = word("koala\nwalks"),
  ok.
