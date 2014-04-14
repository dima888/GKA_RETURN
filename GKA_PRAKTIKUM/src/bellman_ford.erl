%% @author foxhound
%% @doc @todo Add description to 'Bellman_Ford'.
%09.04.14 -> 3std
%10.04.14 -> 3std
%13.04.14 -> 3std

%Quelle: http://de.wikipedia.org/wiki/Bellman-Ford-Algorithmus
%Quelle: http://fuzzy.cs.uni-magdeburg.de/studium/graph/txt/duvigneau.pdf
%01  für jedes v aus V                   
%02      Distanz(v) := unendlich, Vorgänger(v) := keiner
%03  Distanz(s) := 0

%04  wiederhole n - 1 mal /Wobei n Anzahl der Knoten und m Anzahl der Kanten im Graphen ist          
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u

%10  für jedes (u,v) aus E                
%11      wenn Distanz(u) + Gewicht(u,v) < Distanz(v) dann
%12          STOPP mit Ausgabe "Es gibt einen Zyklus negativen Gewichtes."

%13  Ausgabe Distanz
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%bellman_ford:initialize(Graph, 1	, graph_adt:getVertexes(Graph), 1).
-module('bellman_ford').

%% ====================================================================
%% API functions
%% ====================================================================
%-export([initializeGraph/1]).
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================


%01  für jedes v aus V                   
%02  Distanz(v) := unendlich, Vorgänger(v) := keiner
%03  Distanz(s) := 0
%------------- AUFRUF METHODE ----------------
initialize(Graph, SourceID) ->	
	VerticesIDList = graph_adt:getVertexes(Graph),
	initialize(Graph, SourceID, VerticesIDList, 1).
%--------- ABBRUCHBEDINGUNG ---------------
initialize(Graph, SourceID, [], Count) -> Graph;
%----------- INTERNE IMPLEMENTATION ----------------
initialize(Graph, SourceID, VerticesIDList, Count) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	CurrentVertexID = lists:nth(Count, VerticesIDList),
	%Den Attribut keiner bei jedem einpflanzen
	ModifyGraph = graph_adt:setValV(CurrentVertexID, predecessor, "empty", Graph),
	if (CurrentVertexID == SourceID) -> 
		   initialize(graph_adt:setValV(SourceID, distance, 0, ModifyGraph), SourceID, lists:delete(SourceID, VerticesIDList), Count);
	true -> 
		   initialize(graph_adt:setValV(CurrentVertexID, distance, 576460752303423488, ModifyGraph), SourceID, lists:delete(CurrentVertexID, VerticesIDList), Count)
	end.

%TODO: Diese Methode soll nicht mehr aufgerufen werden!!!
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
algoStepTwoU(Graph, Count, OverCount) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	%TODO: Hier bei ungerichtet, muss noch in die andere Richtung geschaut werden, bis jetzt wird nur in eine Richtung geguckt!
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1

	if (Count == EdgeSize + 1) -> 
			overAlgoStepTwoU(Graph, OverCount + 1);
	   true -> 
			Edge = lists:nth(Count, EdgesU),
			
			%Hier hollen wir uns jetzt u und v und pruefen //Schritt 5
			
			%u VertexID hollen
			UvertexID = erlang:element(1, lists:nth(2, Edge)),
			
			%Von u die Distance hollen
			Udistance = graph_adt:getValV(UvertexID, distance, Graph), 
			
			%v VertexID hollen
			VvertexID = erlang:element(2 , lists:nth(2, Edge)),
			
			%Von v die Distance hollen
			Vdistance = graph_adt:getValV(VvertexID, distance, Graph), 
			
			%Gewicht der Kante(u, v) hollen
			Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			
			Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
			
%06			 wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
			if ( (Udistance + Cost_u_v) < Vdistance  ) -> 
				   ModifyGraph = graph_adt:setValV(VvertexID, distance, Udistance + Cost_u_v, Graph),
				   algoStepTwoU(graph_adt:setValV(VvertexID, predecessor, UvertexID, ModifyGraph), Count + 1, OverCount);
			   
%% 			   ( (Vdistance + Cost_u_v) < Udistance  ) ->
%% 				   io:fwrite("Ich bin in else if"),
%% 				   ModifyGraph = graph_adt:setValV(UvertexID, distance, Vdistance + Cost_u_v, Graph),
%% 				   algoStepTwoU(graph_adt:setValV(UvertexID, predecessor, VvertexID, ModifyGraph), Count + 1, OverCount);
			   %TODO: Hier noch ein else if rein hauen und Udistance mit Vdistance vertauschen

			   true -> algoStepTwoU(Graph, Count + 1, OverCount)
			end
	end.

	%VvertexID_2 = erlang:element(2, lists:nth(2, EdgesD)),
	

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%L = bellman_ford:initialize(Graph, 1).
%bellman_ford:overAlgoStepTwoU(L, 1).

%Dieses noch mal Knotenanzahl -1 mal ausfuehren //Count muss 1 sein!
overAlgoStepTwoU(Graph, OverCount) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Herausfinden wie viele Knoten wir ueberhaupt haben
	VerticesCount = erlang:length(Vertices),
	
	%Hier muss das n erhoeht werden, bis n-1 //Schritt 4
	if (VerticesCount - 1 == OverCount) -> 
		   Graph;
	   true -> 
			algoStepTwoU(Graph, 1, OverCount)		   
	end.


%10  für jedes (u,v) aus E                
%11      wenn Distanz(u) + Gewicht(u,v) < Distanz(v) dann
%12          STOPP mit Ausgabe "Es gibt einen Zyklus negativen Gewichtes."
%Count muss mit 1 initialisiert werden
%----------- ABBRUCHBEDINGUNG ------------
negativeCircleCheck(Graph, Count, Whatever) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1

	if ( EdgeSize + 1 == Count ) -> % + 1, weil index nicht bei null beginnt, sondern bei 1
		   Graph;
	   true -> negativeCircleCheck(Graph, Count)
	end.
	
negativeCircleCheck(Graph, Count) -> 
		{ Vertices, EdgesD, EdgesU } = Graph,
	
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1

	Edge = lists:nth(Count, EdgesU),
			
	%u VertexID hollen
	UvertexID = erlang:element(1, lists:nth(2, Edge)),
			
	%Von u die Distance hollen
	Udistance = graph_adt:getValV(UvertexID, distance, Graph), %getValV funktioniert nicht!
			
	%v VertexID hollen
	VvertexID = erlang:element(2 , lists:nth(2, Edge)),
			
	%Von v die Distance hollen
	Vdistance = graph_adt:getValV(VvertexID, distance, Graph), %funktioniert nicht!
			
	%Gewicht der Kante(u, v) hollen
	Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			
	Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
			
%06			 wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
	if ( (Udistance + Cost_u_v) < Vdistance  ) -> 
			   zyklusNegativerLaengerGefunden;
		true -> negativeCircleCheck(Graph, Count + 1, "") %Abbruchbedingung checken
	end.



%------------------------------- DIRECTED IMPLEMENTATION BELLMAN & FORD -------------------------
%TODO: Diese Methode soll nicht mehr aufgerufen werden!!!
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
algoStepTwoDirected(Graph, Count, OverCount) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1
	io:fwrite("A"),
	if (Count == EdgeSize + 1) -> 
			overAlgoStepTwoDirected(Graph, OverCount + 1);
	   true -> 
			Edge = lists:nth(Count, EdgesD),
			io:fwrite("AB"),		
			%Hier hollen wir uns jetzt u und v und pruefen //Schritt 5
			
			%u VertexID hollen
			UvertexID = erlang:element(1, lists:nth(2, Edge)),
			io:fwrite("ABC"),
			%Von u die Distance hollen
			Udistance = graph_adt:getValV(UvertexID, distance, Graph),
			io:fwrite("ABCD"),
			%v VertexID hollen
			VvertexID = erlang:element(2 , lists:nth(2, Edge)),
			io:fwrite("ABCDE"),
			%Von v die Distance hollen
			Vdistance = graph_adt:getValV(VvertexID, distance, Graph),
			io:fwrite("ABCDEF"),
			%Gewicht der Kante(u, v) hollen
			Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			io:fwrite("ABCDEFG"),
			Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
			
%06			 wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
			if ( (Udistance + Cost_u_v) < Vdistance  ) -> 
				   ModifyGraph = graph_adt:setValV(VvertexID, distance, Udistance + Cost_u_v, Graph),
				   algoStepTwoDirected(graph_adt:setValV(VvertexID, predecessor, UvertexID, ModifyGraph), Count + 1, OverCount);
			   true -> algoStepTwoDirected(Graph, Count + 1, OverCount)
			end
	end.
	

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%L = bellman_ford:initialize(Graph, 1).
%A = bellman_ford:addEdgesUInverse(L).
%bellman_ford:overAlgoStepTwoDirected(A, 1).

%Dieses noch mal Knotenanzahl -1 mal ausfuehren //Count muss 1 sein!
overAlgoStepTwoDirected(Graph, OverCount) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Herausfinden wie viele Knoten wir ueberhaupt haben
	VerticesCount = erlang:length(Vertices),
	
	%Hier muss das n erhoeht werden, bis n-1 //Schritt 4
	if (VerticesCount - 1 == OverCount) -> 
		   Graph;
	   true -> 
			algoStepTwoDirected(Graph, 1, OverCount)		   
	end.





% ----------------- HILFSMETHODEN --------------------- 
addEdgesUInverse(Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1
	addEdgesUInverse(Graph, 1, EdgeSize).
addEdgesUInverse(Graph, Count, EdgeSize) ->
		{ Vertices, EdgesD, EdgesU } = Graph,
	
	if (Count == EdgeSize + 1) -> 
		   SuperEdge = lists:append(EdgesD, EdgesU),
 		   { Vertices, SuperEdge, EdgesU };
	   true -> 
			Edge = lists:nth(Count, EdgesU),
		   
			%u VertexID hollen
        			UvertexID = erlang:element(1, lists:nth(2, Edge)),
		   
			%v VertexID hollen
			VvertexID = erlang:element(2 , lists:nth(2, Edge)),
		   
			%Kosten aus der Kante hollen
			EdgeCost = lists:nth(2, lists:nth(3, Edge)),
		   
			%Umgekehrte Kante hinzufuegen
			ModifyGraph = graph_adt:addEdgeD(VvertexID, UvertexID, Graph),
		   	ModifyGraph_2 = graph_adt:setValE({VvertexID, UvertexID}, cost, EdgeCost, ModifyGraph),
		   
			%rekursiv alle Kanten durch laufen
			addEdgesUInverse(ModifyGraph_2, Count + 1, EdgeSize)

	end.
	

% ---------- TRASH --------------
setAttributsV(Graph, []) -> Graph;
setAttributsV(Graph, [H|T]) ->
	% ID des Knoten abspeichern
 	ID = lists:nth(2, H), 
	setAttributsV(graph_adt:setValV(ID, distance, 0, Graph), T).
	


