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

%TODO: Fuer den ungerichteten Graphen kann ich wieder den spezial Trick benutzen
%Initialisiert die Distanz und Transit Matix

%Aufruf der Methode // %Das n unsere quadratischen 2d Matrix
%Gibt einer Liste von zwei Matrizen zurueck, 
%[1] -> Distance Matrix; [2] -> Transit Matrix
initialize(Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	initialize_Termination_Check(Graph, [], [], 1, erlang:length(graph_adt:getVertexes(Graph)), graph_adt:getVertexes(Graph), erlang:length(Vertices)).
	
%Abbruchbedinung wird hier definiert
initialize_Termination_Check(Graph, Distance_Matrix, Transit_Matrix, Current_ID_Index, Terminate, Vertices_List, N) ->
	if (Current_ID_Index == Terminate + 1) -> 
		   %Result
		   [Distance_Matrix, Transit_Matrix]; 
	true -> 
		initialize(Graph, Distance_Matrix, Transit_Matrix, graph_adt:getVertexes(Graph), Current_ID_Index, Terminate, Vertices_List, N, 1, [], [])
	end.

%graph_parser:importGraph("c:\\users\\foxhound\\desktop\\floyd.txt", "cost").
%floyd_warshall:initialize(graph_parser:importGraph("c:\\users\\foxhound\\desktop\\floyd.txt", "cost")).
%Interne implementation
initialize(Graph, Distance_Matrix, Transit_Matrix, Vertices_List, Current_ID_Index, Terminate, Vertices_List, N, Index, Inner_Distance_Matrix, Inner_Transit_Matrix) -> 
	Current_ID = lists:nth(Current_ID_Index, Vertices_List),
	Current_ID_In_Vertices_List = lists:nth(Index, Vertices_List),
	
	if ( Current_ID == Current_ID_In_Vertices_List ) ->   
		   Modify_Inner_Distance_Matrix = Inner_Distance_Matrix ++ [0];
	   true -> 
		   
		    %Attribut Kosten aus der Kante hollen, falls die Kante vorhanden ist, sonst nil
			Cost_From_Any_Edge = graph_adt:getValE({Current_ID, Current_ID_In_Vertices_List}, cost, Graph),
			
			%Wenn Kante Vorhanden ist, dann Inner_Matirx mit seinen Kosten setzten, sonst mit unendlich
			if ( Cost_From_Any_Edge == nil) ->
				   Modify_Inner_Distance_Matrix = Inner_Distance_Matrix ++ [576460752303423488];
			   true -> 
				   %io:fwrite("gebe Kosten zurueck"),
				   Modify_Inner_Distance_Matrix = Inner_Distance_Matrix ++ [element(1, string:to_integer(Cost_From_Any_Edge))]
			end
	end, 
	
	%TransitMatrix initialisieren
	Modify_Inner_Transit_Matrix = Inner_Transit_Matrix ++ [0],

	%io:write(Vertices_List), io:fwrite("----"), io:write(Current_ID_Index), io:fwrite("----"), io:write(Index),
	if ( Index == Terminate ) ->
		   initialize_Termination_Check(Graph, Distance_Matrix ++ [Modify_Inner_Distance_Matrix], Transit_Matrix ++ [Modify_Inner_Transit_Matrix], Current_ID_Index + 1, Terminate, Vertices_List, N) ;
	   true -> initialize(Graph, Distance_Matrix, Transit_Matrix, Vertices_List, Current_ID_Index, Terminate, Vertices_List, N, Index + 1, Modify_Inner_Distance_Matrix, Modify_Inner_Transit_Matrix) 
	end.


%TODO: Oberste "schleife" Fuer j = 1, ..., |V|:
highLevel(Distance_Matrix, Transit_Matrix, J) -> 
	

	middleLevel(Distance_Matrix, Transit_Matrix, J, 1).




%TODO: Die mittlere "schleife" die in der Oberen laeuft: Fuer i = 1,....,|V|; 
%k =/= j -> Gehe in noch eine tiefere "Schleife" von mittlere "Schleife" und fuehre da 
%folgendes aus: Setzte d_ik = min{d_ik, d_ij + djk}
middleLevel(Distance_Matrix, Transit_Matrix, J, I) -> 
	
	%TODO: Wenn die Schleife Durchgelaufen ist, dann zu Highlevel und J + 1
	
	%Falls d_ii < 0 ist, brich den Algorithmus vorzeitig ab. (Kreis negativer Laenge gefunden)
	Elem_i_i = lists:nth(I, lists:nth(I, Distance_Matrix)),
	
	if (Elem_i_i < 0) -> 
		   es_wurde_ein_Kreis_negativer_Laenge_gefunden;
	   true -> 
		   %Fuer den Fall, wenn i =/= j ist
			if ( i =/= j ) -> 
				   %lowLevel betretten
					lowLevel(Distance_Matrix, Transit_Matrix, J, I, 1);
			   true -> 
				   %Algorithmus weiter ausfuereh ( i == j )
					middleLevel(Distance_Matrix, Transit_Matrix, J, I + 1)
			end
	end.

%TODO: %folgendes aus: Setzte d_ik = min{d_ik, d_ij + djk}
lowLevel(Distance_Matrix, Transit_Matrix, J, I, K) -> 
	
	%TODO: Wenn die Schleife durch gelaufen ist, dann zu middleLevel und I + 1
	
	% k =/= j
	if (K =/= J) ->
		   X = 24;
	   true -> 
		   lowLevel(Distance_Matrix, Transit_Matrix, J, I, K + 1)
	end.
	






















