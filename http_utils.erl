-module(http_utils).
-export([token/1]).

token(Text) -> word(Text, " \t\r\n").
word(Text, Delims) -> word(Text, Delims, []).

word([], Delims, Acc) -> word_ret(Acc, []);
word([H|T], Delims, Acc) -> word(T, H, Delims, Acc, string:chr(Delims, H) == 0).

word(T, H, Delims, [], false) -> word(T, Delims, []);
word(T, H, Delims, Acc, false) -> word_ret(Acc, T);
word(T, H, Delims, Acc, _) -> word(T, Delims, [H|Acc]).

word_ret(Word, Tail) -> {lists:reverse(Word), Tail}.
