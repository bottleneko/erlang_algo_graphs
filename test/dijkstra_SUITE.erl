-module(dijkstra_SUITE).

-compile(export_all).
-compile(nowarn_export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

-include_lib("erlang_data_structures/include/data_structures.hrl").

all() ->
  [
    primitive_path_test,
    primitive_bidirectional_edges_path_test,
    primitive_split_path_test,
    triple_split_path_test
  ].

primitive_path_test(_Config) ->
  Edges = [{{1, 2}, 1}, {{2, 3}, 1}],
  Graph = directed_weighted_graph:from_list(Edges),
  Paths = dijkstra:shortest_paths(1, Graph),
  ?assertEqual([{1, 0}, {2, 1}, {3, 2}], Paths).

primitive_bidirectional_edges_path_test(_Config) ->
  Edges = [{{1, 2}, 1}, {{2, 3}, 1}, {{2, 1}, 1}, {{3, 2}, 1}],
  Graph = directed_weighted_graph:from_list(Edges),
  Paths = dijkstra:shortest_paths(1, Graph),
  ?assertEqual([{1, 0}, {2, 1}, {3, 2}], Paths).

primitive_split_path_test(_Config) ->
  Edges = [{{1, 2}, 1}, {{2, 3}, 1}, {{1, 3}, 1}],
  Graph = directed_weighted_graph:from_list(Edges),
  Paths = dijkstra:shortest_paths(1, Graph),
  ?assertEqual([{1, 0}, {2, 1}, {3, 1}], Paths).

triple_split_path_test(_Config) ->
  Edges = [{{1, 2}, 1}, {{1, 3}, 1}, {{1, 4}, 1}, {{2, 5}, 1}, {{3, 5}, 2}, {{4, 5}, 3}],
  Graph = directed_weighted_graph:from_list(Edges),
  Paths = dijkstra:shortest_paths(1, Graph),
  ?assertEqual([{1, 0}, {2, 1}, {3, 1}, {4, 1}, {5, 2}], Paths).