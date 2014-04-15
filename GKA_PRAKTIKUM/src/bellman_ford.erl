%% @author foxhound
%% @doc @todo Add description to 'Bellman_Ford'.
%09.04.14 -> 3std
%10.04.14 -> 3std
%13.04.14 -> 3std
%14.04.14 -> 3std
%15.04.14 -> 3std
%Fuer Bellman_Ford habe ich 12 Stunden gebraucht

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
-module('bellman_ford').

%% ====================================================================
%% API functions
%% ====================================================================
%-export([initializeGraph/1]).
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
% --------------------------------------- HAUPT METHODE --------------------------------------
startAlgorithm(Graph, SourceID, TargetID) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Graphen inizialwerte verpassen
	ModifyGraph = initialize(Graph, SourceID),
	
	%Referenzieren zwischen gerichteten und ungerichteten Graphen
	if ( erlang:length(EdgesD) == 0) ->	   
	%----------- DER FALL FUER UNGERICHTETEN GRAPHEN -----------

	%Spezial Trick fuer ungerichteten Graph um alle Kanten durch zu laufen
	ModifyGraph_2 = addEdgesUInverse(ModifyGraph), 
	
	%Algorithmus zum rechnen starten
	ModifyGraph_3 = controlOfcalculationPhase(ModifyGraph_2, 1), %1, weil wir bei 1 anfangen zu zaehlen!

	%Auf negative Kanten Pruefen
	ModifyGraph_4 = negativeCircleCheckForDirected(ModifyGraph_3, 1), %Auch hier fangen wir natuerlich an bei 1 hoch zu zaehlen!

	%Spezial Trick wieder rueckgaengig machen, muss nicht sein, finde ich aber schoener!
	ModifyGraph_5 = { erlang:element(1, ModifyGraph_4), [], erlang:element(3, ModifyGraph_4) },
	
	%Result -> Distance zur Knoten Target
	graph_adt:getValV(TargetID, distance, ModifyGraph_5);

	true -> 
	%------------ DER FALL FUER GERICHTETEN GRAPHEN ------------
	
	%Algorithmus zum rechnen starten
	ModifyGraph_2 = controlOfcalculationPhase(ModifyGraph, 1), %1, weil wir bei 1 anfangen zu zaehlen!
 
	%Auf negative Kanten Pruefen
	ModifyGraph_3 = negativeCircleCheckForDirected(ModifyGraph_2, 1), %Auch hier fangen wir natuerlich an bei 1 hoch zu zaehlen!

	graph_adt:getValV(TargetID, distance, ModifyGraph_3)
	end.
	
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
	CurrentVertexID = lists:nth(Count, VerticesIDList),
	%Den Attribut keiner bei jedem einpflanzen
	ModifyGraph = graph_adt:setValV(CurrentVertexID, predecessor, "empty", Graph),
	if (CurrentVertexID == SourceID) -> 
		   initialize(graph_adt:setValV(SourceID, distance, 0, ModifyGraph), SourceID, lists:delete(SourceID, VerticesIDList), Count);
	true -> 
		   initialize(graph_adt:setValV(CurrentVertexID, distance, 576460752303423488, ModifyGraph), SourceID, lists:delete(CurrentVertexID, VerticesIDList), Count)
	end.

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
calculationPhase(Graph, Count, OverCount) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1
	
	if (Count == EdgeSize + 1) -> 
			controlOfcalculationPhase(Graph, OverCount + 1);
	   true -> 
			Edge = lists:nth(Count, EdgesD),
	
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
			if ( ( (Udistance + (Cost_u_v)) < Vdistance ) ) -> 
				   ModifyGraph = graph_adt:setValV(VvertexID, distance, (Udistance + (Cost_u_v)), Graph),
				   calculationPhase(graph_adt:setValV(VvertexID, predecessor, UvertexID, ModifyGraph), Count + 1, OverCount);
			   true -> calculationPhase(Graph, Count + 1, OverCount)
			end
	end.

%Dieses noch mal Knotenanzahl -1 mal ausfuehren //Count muss 1 sein!
controlOfcalculationPhase(Graph, OverCount) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Herausfinden wie viele Knoten wir ueberhaupt haben
	VerticesCount = erlang:length(Vertices),
	
	%Hier muss das n erhoeht werden, bis n-1 //Schritt 4
	if (VerticesCount - 1 == OverCount) -> 
		   Graph;
	   true -> 
			calculationPhase(Graph, 1, OverCount)		   
	end.

%------------------------------------------ NEGATIVEN ZYKLUS ERMITTELN ------------------------------------------ 
%10  für jedes (u,v) aus E                
%11      wenn Distanz(u) + Gewicht(u,v) < Distanz(v) dann
%12          STOPP mit Ausgabe "Es gibt einen Zyklus negativen Gewichtes."
%Count muss mit 1 initialisiert werden
%----------- ABBRUCHBEDINGUNG ------------
negativeCircleCheckForDirected(Graph, Count, Whatever) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1

	if ( EdgeSize + 1 == Count ) -> % + 1, weil index nicht bei null beginnt, sondern bei 1
		   Graph;
	   true -> negativeCircleCheckForDirected(Graph, Count)
	end.
	
negativeCircleCheckForDirected(Graph, Count) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1

	Edge = lists:nth(Count, EdgesD),
			
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
		true -> negativeCircleCheckForDirected(Graph, Count + 1, "") %Abbruchbedingung checken
	end.

%10  für jedes (u,v) aus E                
%11      wenn Distanz(u) + Gewicht(u,v) < Distanz(v) dann
%12          STOPP mit Ausgabe "Es gibt einen Zyklus negativen Gewichtes."
%Count muss mit 1 initialisiert werden
%----------- ABBRUCHBEDINGUNG ------------
negativeCircleCheckForUndirected(Graph, Count, Whatever) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1

	if ( EdgeSize + 1 == Count ) -> % + 1, weil index nicht bei null beginnt, sondern bei 1
		   Graph;
	   true -> negativeCircleCheckForUndirected(Graph, Count)
	end.
	
negativeCircleCheckForUndirected(Graph, Count) -> 
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
		true -> negativeCircleCheckForUndirected(Graph, Count + 1, "") %Abbruchbedingung checken
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


	

