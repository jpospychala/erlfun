-module(integration_test).
-include_lib("eunit/include/eunit.hrl").

sample_app_sum_test() ->
  inets:start(),
  Pid = spawn(sample_app, main, []),
  {ok, {{_, 200, _}, _, "6"}} = httpc:request("http://localhost:8888/sum?a=1&b=5"),
  exit(Pid, kill),
  ok.
