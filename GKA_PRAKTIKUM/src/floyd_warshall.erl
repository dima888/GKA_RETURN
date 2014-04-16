%% @author foxhound
%% @doc @todo Add description to floyd_warshall.
%16.04.2014 -> 3std.

-module(floyd_warshall).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).



%% ====================================================================
%% Internal functions
%% ====================================================================

%Initialisiert die Distanz und Transit Matix

%Aufruf der Methode // %Das n unsere quadratischen 2d Matrix
initialize(Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	initialize_Termination_Check(Graph, [], [], 1, erlang:length(graph_adt:getVertexes(Graph)) +1, graph_adt:getVertexes(Graph), erlang:length(Vertices)).
	
%Abbruchbedinung wird hier definiert
initialize_Termination_Check(Graph, Distance_Matrix, Transit_Matrix, Current_ID_Index, Terminate, Vertices_List, N) ->
	if (Current_ID_Index == Terminate) -> 
		   Distance_Matrix;
	true -> 
		initialize(Graph, Distance_Matrix, Transit_Matrix, graph_adt:getVertexes(Graph), Current_ID_Index, Terminate, Vertices_List, N)
	end.

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%Interne implementation
initialize(Graph, Distance_Matrix, Transit_Matrix, Vertices_List, Current_ID_Index, Terminate, Vertices_List, N) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	
	State = [graph_adt:getValV(X, name, Graph) || X <- Vertices_List, Current_ID_Index =/= X],
	
	initialize_Termination_Check(Graph, Distance_Matrix  ++ [State], Transit_Matrix, Current_ID_Index + 1, Terminate, Vertices_List, N).




















