-module(http_utils).
-export([token/1, query_string/1]).

token(Text) -> word(Text, " \t\r\n").
word(Text, Delims) -> word(Text, Delims, []).

word([], _, Acc) -> word_ret(Acc, []);
word([H|T], Delims, Acc) -> word(T, H, Delims, Acc, string:chr(Delims, H) == 0).

word(T, _, Delims, [], false) -> word(T, Delims, []);
word(T, _, _, Acc, false) -> word_ret(Acc, T);
word(T, H, Delims, Acc, _) -> word(T, Delims, [H|Acc]).

word_ret(Word, Tail) -> {lists:reverse(Word), Tail}.

query_string("?" ++ Str) -> query_string(Str);
query_string(Str) ->
  Params = string:tokens(Str, "&"),
  [list_to_tuple(string:tokens(Param,"=")) || Param <- Params].
