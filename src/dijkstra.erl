-module(dijkstra).
-author("neko").

-export([
  shortest_paths/2
]).

-include_lib("erlang_data_structures/include/data_structures.hrl").

shortest_paths(FromVertex, Graph) ->
  directed_weighted_graph:incident_edges(FromVertex, Graph),
  ProcessingQueue = binary_heap:new(),
  PathToLengths = gb_trees:insert(FromVertex, 0, gb_trees:empty()),
  Visited = gb_sets:new(),
  shortest_paths_T({0, FromVertex}, ProcessingQueue, PathToLengths, Visited, Graph).

shortest_paths_T(undefined, _ProcessingQueue, PathToLengths, _Visited, _Graph) ->
  gb_trees:to_list(PathToLengths);
shortest_paths_T({Length, Vertex}, ProcessingQueue, PathToLengths, Visited, Graph) ->
  case gb_sets:is_member(Vertex, Visited) of
    true ->
      {Peek, NewQueue} = binary_heap:extract_peek(ProcessingQueue),
      shortest_paths_T(Peek, NewQueue, PathToLengths, Visited, Graph);
    false ->
      Edges = directed_weighted_graph:incident_edges(Vertex, Graph),
      {ExtendedQueue, NewPathToLength} = lists:foldl(
        fun
          (#weighted_edge{route = {IVertex, Destination}, weight = Weight}, {Queue, Paths}) when IVertex =:= Vertex ->
            PLength = min(Weight + Length,
              safe_get_gb_tree(Destination, Paths)),
            NPaths = safe_insert_gb_tree(Destination, PLength, Paths),
            NQueue = binary_heap:insert({PLength, Destination}, Queue),
            {NQueue, NPaths};
          (#weighted_edge{route = {_IVertex, _Destination}, weight = _Weight}, {Queue, Paths}) ->
            {Queue, Paths}
        end, {ProcessingQueue, PathToLengths}, Edges),
      NewVisited = gb_sets:balance(gb_sets:add(Vertex, Visited)),
      {Peek, NewQueue} = binary_heap:extract_peek(ExtendedQueue),
      shortest_paths_T(Peek, NewQueue, NewPathToLength, NewVisited, Graph)
  end.

safe_insert_gb_tree(Key, Value, Tree) ->
  case gb_trees:is_defined(Key, Tree) of
    true ->
      gb_trees:update(Key, Value, Tree);
    false ->
      gb_trees:insert(Key, Value, Tree)
  end.

safe_get_gb_tree(Key, Tree) ->
  case gb_trees:lookup(Key, Tree) of
    {value, Value} ->
      Value;
    none -> none
  end.