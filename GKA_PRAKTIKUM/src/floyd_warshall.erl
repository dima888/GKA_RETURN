%% @author foxhound
%% @doc @todo Add description to floyd_warshall.
%16.04.2014 -> 3std.
%19.04.2014 -> 3std.
%20.04.2014 -> 3std.

-module(floyd_warshall).

%Algorithmus aus dem GRBuch Seite 53
%% dij := 
%% (
%% lij für vivj element E und i 6= j
%% 0 für i = j
%% Unendlich sonst
%% tij := 0

%% Für j = 1, . . . , |V |:
%% * Für i = 1, . . . , |V |; i 6= j:
%% - Für k = 1, . . . , |V |; k 6= j:
%% ** Setze dik := min{dik, dij + djk}.
%% ** Falls dik verändert wurde, setze tik := j.
%% - Falls dii < 0 ist, brich den Algorithmus vorzeitig ab. (Es wurde ein
%% Kreis negativer Länge gefunden.)

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================

%Initialisiert die Distanz und Transit Matix

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\floyd.txt", "cost").
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\graph8.txt", "cost").
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\graph2.txt", "cost").
%Nur diese Methode soll aufgerufen werden
startAlgorithm(Graph, Source_ID, Target_ID) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
		
	%Referenzieren zwischen gerichteten und ungerichteten Graphen
	if ( erlang:length(EdgesD) == 0) ->	   
		   
	%----------- DER FALL FUER UNGERICHTETEN GRAPHEN -----------

	%SpezialTrick anwenden
	Modify_Graph = lists:nth(1, bellman_ford:addEdgesUInverse(Graph, 1)),
		   
	Distance_Transite_Matrix = initialize(Modify_Graph),	
		
	%Berechnete Matritzen: [1] -> Distance Matrix; [2] -> Transit Matrix
	Result_Distance_Transit_Matrix = highLevel(lists:nth(1, Distance_Transite_Matrix), lists:nth(2, Distance_Transite_Matrix), 1),
	
	%Result -> Die Distance zwischen Zwei Knoten
	Distance_Matrix = lists:nth(1, Result_Distance_Transit_Matrix),

	%Indezes ermitteln, durch die Vertices List, an welcher Stelle Source ID oder Target ID
	%Steht ist der Index der Distance Matrix auf die ich zugreifen muss. 
	VerticesList = graph_adt:getVertexes(Graph),	
	Index_Of_Source_ID = index_of(Source_ID, VerticesList),
	Index_Of_Target_ID = index_of(Target_ID, VerticesList),
	
	%Spezial Trick wieder rueckgaengig machen, muss nicht sein, finde ich aber schoener!
	Modify_Graph_2 = { erlang:element(1, Modify_Graph), [], erlang:element(3, Modify_Graph) },
	
	%Result
	io:fwrite("Zugriffe auf den Graph: "), io:write(1), io:fwrite(" || Optimale Route: "), io:write(lists:nth(Index_Of_Target_ID, lists:nth(Index_Of_Source_ID, Distance_Matrix))), io:nl(),
	io:fwrite("Distance Matrix: "), io:write(lists:nth(1, Result_Distance_Transit_Matrix)), io:nl(),
	io:fwrite("Transit Matrix: "), io:write(lists:nth(2, Result_Distance_Transit_Matrix)), io:nl(),
	io:fwrite("Running Way in Vertices ID: "), io:write(floyd_warshall:showWayFromTransitMatrix(lists:nth(2, Result_Distance_Transit_Matrix), Source_ID, Target_ID, graph_adt:getVertexes(Graph))), io:nl(),

	
	wir_sind_fertig;
	true ->

		%------------ DER FALL FUER GERICHTETEN GRAPHEN ------------
	
	%Initialisierungsphase [1] -> Distance Matrix; [2] -> Transit Matrix
	Distance_Transite_Matrix = initialize(Graph),	
		
	%Berechnete Matritzen: [1] -> Distance Matrix; [2] -> Transit Matrix
	Result_Distance_Transit_Matrix = highLevel(lists:nth(1, Distance_Transite_Matrix), lists:nth(2, Distance_Transite_Matrix), 1),
	
	%Result -> Die Distance zwischen Zwei Knoten
	Distance_Matrix = lists:nth(1, Result_Distance_Transit_Matrix),

	%Indezes ermitteln, durch die Vertices List, an welcher Stelle Source ID oder Target ID
	%Steht ist der Index der Distance Matrix auf die ich zugreifen muss. 
	VerticesList = graph_adt:getVertexes(Graph),	
	Index_Of_Source_ID = index_of(Source_ID, VerticesList),
	Index_Of_Target_ID = index_of(Target_ID, VerticesList),
	
	%Result
	%io:fwrite("Zugriffe auf den Graph: "), io:write(1), io:fwrite(" || Optimale Route: "),
	io:fwrite("Zugriffe auf den Graph: "), io:write(1), io:fwrite(" || Optimale Route: "), io:write(lists:nth(Index_Of_Target_ID, lists:nth(Index_Of_Source_ID, Distance_Matrix))), io:nl(),
	io:fwrite("Distance Matrix: "), io:write(lists:nth(1, Result_Distance_Transit_Matrix)), io:nl(),
	io:fwrite("Transit Matrix: "), io:write(lists:nth(2, Result_Distance_Transit_Matrix)), io:nl(),
	io:fwrite("Running Way in Vertices ID: "), io:write(floyd_warshall:showWayFromTransitMatrix(lists:nth(2, Result_Distance_Transit_Matrix), Source_ID, Target_ID, graph_adt:getVertexes(Graph))), io:nl(),
	%io:fwrite("Running Way in Vertices ID: "), floyd_warshall:showWayFromTransitMatrix(Graph, Source_ID, Target_ID),

	wir_sind_fertig
	end.


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

%Oberste "schleife" Fuer j = 1, ..., |V|:
highLevel(Distance_Matrix, Transit_Matrix, J) -> 

	Terminate = erlang:length(Distance_Matrix),
	
	if ( J > Terminate ) ->
		   [Distance_Matrix, Transit_Matrix];
	true ->
	middleLevel(Distance_Matrix, Transit_Matrix, J, 1)
	end.

%Die mittlere "schleife" die in der Oberen laeuft: Fuer i = 1,....,|V|; 
%k =/= j -> Gehe in noch eine tiefere "Schleife" von mittlere "Schleife" und fuehre da 
%folgendes aus: Setzte d_ik = min{d_ik, d_ij + djk}
middleLevel(Distance_Matrix, Transit_Matrix, J, I) -> 
	
	Terminate = erlang:length(Distance_Matrix),
	
	if (I > Terminate) ->
		   highLevel(Distance_Matrix, Transit_Matrix, J + 1);
	true ->
	
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
	end
end.

%folgendes aus: Setzte d_ik = min{d_ik, d_ij + djk}
lowLevel(Distance_Matrix, Transit_Matrix, J, I, K) -> 
	
	Terminate = erlang:length(Distance_Matrix),
	if (K > Terminate) -> 
		   middleLevel(Distance_Matrix, Transit_Matrix, J, I + 1);
	true -> 
	
	% k =/= j
	if (K =/= J) ->
		   
		    %d_ik ermitteln
			Elem_i_k = lists:nth(K, lists:nth(I, Distance_Matrix)),
			
			%d_ij ermitteln
			Elem_i_j = lists:nth(J, lists:nth(I, Distance_Matrix)),
			
			%d_jk ermitteln
			Elem_j_k = lists:nth(K, lists:nth(J, Distance_Matrix)), 
			
			%Dieses Element kommt an die Stelle d_ik
			To_Install_Elem = erlang:min(Elem_i_k, Elem_i_j + Elem_j_k),
			
			%Jetzt kommt der komplizierte Teil, jedoch nur in Erlang kompliziert, das Element einsetzten
			
			%Gib mir Alle Listen vor I
			Head = lists:sublist(Distance_Matrix, I-1),
			
			%Gib mir Alle Listen Nach I
			Tail = lists:nthtail(I, Distance_Matrix),
		   
			%Gib mir die Liste, in der ein Element Modifiziert wird
			Middle = lists:nth(I, Distance_Matrix),
			
			%Jetzt hollen wir uns wieder die Teile aus der Liste Middle
			Middle_Head = lists:sublist(Middle, K-1),
			Middle_Tail = lists:nthtail(K, Middle),
			
			%Modifizierte Distance Matrix zusammen bauen
			Modify_Middle = Middle_Head ++ [To_Install_Elem] ++ Middle_Tail,			
			Modify_Distance_Matrix = Head ++ [Modify_Middle] ++ Tail,
		   
			%io:write(Modify_Distance_Matrix), io:nl(), io:fwrite("-------------"), io:nl(),
			
			%Falls was in d_ik gesetzt wurde, dann t_ik ermitteln und = j setzten
			if (To_Install_Elem =/= Elem_i_k) ->
				   
				   %Gib mir die Liste vor I
				   Head_T = lists:sublist(Transit_Matrix, I - 1),
				   
				   %Gib mir die Liste nach I
				   Tail_T = lists:nthtail(I, Transit_Matrix),
				   
				   %Gib mir die Liste, in der ein Element Modifiziert wird
				   Middle_T = lists:nth(I, Transit_Matrix),
				   
				   %Jetzt hollen wir uns wieder die Teile aus der Liste Middle
				   Middle_Head_T = lists:sublist(Middle_T, K-1),
				   Middle_Tail_T = lists:nthtail(K, Middle_T),
			
				   %Modifizierte Transitmatrix zusammen bauen
				   Modify_Middle_T = Middle_Head_T ++ [J] ++ Middle_Tail_T,
				   Modify_Transit_Matrix = Head_T ++ [Modify_Middle_T] ++ Tail_T,
				   lowLevel(Modify_Distance_Matrix, Modify_Transit_Matrix, J, I, K + 1);
			   
			true ->
				lowLevel(Modify_Distance_Matrix, Transit_Matrix, J, I, K + 1)
			end;
			
	   true -> 
		   lowLevel(Distance_Matrix, Transit_Matrix, J, I, K + 1)
	end
end.

%Die Methode die aufgerufen wird
showWayFromTransitMatrix(Transit_Matrix, Source_ID, Target_ID, Vertices_List) ->
	
	%Tran = floyd_warshall:startAlgorithm(Graph, Source_ID, Target_ID),
	%io:write(Tran), io:nl(),
	Running_Way = [Target_ID],
	
	%VerticesList = graph_adt:getVertexes(Graph),
	
	%Von den IDs die Indizes herausfinden
	I = index_of(Source_ID, Vertices_List),
	J = index_of(Target_ID, Vertices_List),
	
	showWayFromTransitMatrix(I, J, Source_ID, Transit_Matrix, Running_Way, Vertices_List).
	
showWayFromTransitMatrix(I, J, Source_ID, Transit_Matrix, Running_Way, Vertices_List) -> 
	
	%VerticesList = graph_adt:getVertexes(Graph),
	%io:fwrite("I = "), io:write(I), io:nl(), io:fwrite("J = "), io:write(J), io:nl(),
	
	%Zugriff auf die Transit Matrix mit Source und Target ID

	%Wenn das Element Null ist, dann haben wir unseren Weg schon rekonstruiert
	Elem_I_J = lists:nth(J, lists:nth(I, Transit_Matrix)),

	%Abbruchbedingung
	if ( Elem_I_J == 0) ->
		   R = Running_Way ++ [Source_ID], 
		   lists:reverse(R);
	true -> 
		showWayFromTransitMatrix(I, Elem_I_J, Source_ID, Transit_Matrix, Running_Way ++ [lists:nth(Elem_I_J, Vertices_List)], Vertices_List)
	end.
	

%----------------------------- HILFSMETHODEN -----------------------------
%QUELLE: stackoverflow.com/questions/1459152/erlang-listsindex-of-function
index_of(Item, List) -> index_of(Item, List, 1).
index_of(_, [], _)  -> not_found;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).
