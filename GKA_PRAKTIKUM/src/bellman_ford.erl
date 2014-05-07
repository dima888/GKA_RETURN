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
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellmanT.txt", "cost").
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\floyd.txt", "cost").
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\graph8.txt", "cost").   

% --------------------------------------- HAUPT METHODE --------------------------------------
startAlgorithm(Graph, SourceID, TargetID) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zaehlt wie oft auf unseren Graphen zugegriffen wurden ist, warum hier bei null? Weil noch kein Zugriff auf den Graph getaetigt wurde!
	AccessOfGraph = 0,
	
	%Graphen inizialwerte verpassen
	ModifyGraph = lists:nth(1, initialize(Graph, SourceID, AccessOfGraph)),
	AccessOfGraphCurrent = lists:nth(2, initialize(Graph, SourceID, AccessOfGraph)),
	
	%Referenzieren zwischen gerichteten und ungerichteten Graphen
	if ( erlang:length(EdgesD) == 0) ->	   
	%----------- DER FALL FUER UNGERICHTETEN GRAPHEN -----------

	%Spezial Trick fuer ungerichteten Graph um alle Kanten durch zu laufen
	ModifyGraph_2 = lists:nth(1, addEdgesUInverse(ModifyGraph, AccessOfGraphCurrent)), 
	AccessOfGraphCurrentU = lists:nth(2, addEdgesUInverse(ModifyGraph, AccessOfGraphCurrent)),
	
	%Algorithmus zum rechnen starten
	ModifyGraph_3 = lists:nth(1, controlOfcalculationPhase(ModifyGraph_2, 1, AccessOfGraphCurrentU)), %1, weil wir bei 1 anfangen zu zaehlen!
	AccessOfGraphCurrentU_2 = lists:nth(2, controlOfcalculationPhase(ModifyGraph_2, 1, AccessOfGraphCurrentU)),
	
	%Auf negative Kanten Pruefen
	ModifyGraph_4 = lists:nth(1, negativeCircleCheck(ModifyGraph_3, 1, AccessOfGraphCurrentU_2)), %Auch hier fangen wir natuerlich an bei 1 hoch zu zaehlen!
	AccessOfGraphCurrentU_3 = lists:nth(2, negativeCircleCheck(ModifyGraph_3, 1, AccessOfGraphCurrentU_2)),
	
	
	%Spezial Trick wieder rueckgaengig machen, muss nicht sein, finde ich aber schoener!
	ModifyGraph_5 = { erlang:element(1, ModifyGraph_4), [], erlang:element(3, ModifyGraph_4) },
	
	io:fwrite("Zugriffe auf den Graph: "), io:write(AccessOfGraphCurrentU_3), io:fwrite(" || Guenstigste Route: "),
	%------------ RETURN VALUE (DISTANCE ZUR KNOTEN TARGET)-----------
	graph_adt:getValV(TargetID, distance, ModifyGraph_5);

	true -> 
	%------------ DER FALL FUER GERICHTETEN GRAPHEN ------------
	
	%Algorithmus zum rechnen starten
	ModifyGraph_2 = lists:nth(1, controlOfcalculationPhase(ModifyGraph, 1, AccessOfGraphCurrent)), %1, weil wir bei 1 anfangen zu zaehlen!
 	AccessOfGraphCurrentD = lists:nth(2, controlOfcalculationPhase(ModifyGraph, 1, AccessOfGraphCurrent)),
	
	%Auf negative Kanten Pruefen
	ModifyGraph_3 = lists:nth(1, negativeCircleCheck(ModifyGraph_2, 1, AccessOfGraphCurrentD)), %Auch hier fangen wir natuerlich an bei 1 hoch zu zaehlen!
	AccessOfGraphCurrentD_2 = lists:nth(2, negativeCircleCheck(ModifyGraph_2, 1, AccessOfGraphCurrentD)),
	
	io:fwrite("Zugriffe auf den Graph: "), io:write(AccessOfGraphCurrentD_2), io:fwrite(" || Guenstigste Route: "),
	%------------ RETURN VALUE (DISTANCE ZUR KNOTEN TARGET)-----------
	graph_adt:getValV(TargetID, distance, ModifyGraph_3)
	end.

%Methode liefert eine Liste zurueck, an erster Stelle den initialisieren Graphen
%und an zweiter Stelle die Anzahl der Zugriffe auf diesen Graphen
%01  für jedes v aus V                   
%02  Distanz(v) := unendlich, Vorgänger(v) := keiner
%03  Distanz(s) := 0
%------------- AUFRUF METHODE ----------------
initialize(Graph, SourceID, AccessOfGraph) ->	
	VerticesIDList = graph_adt:getVertexes(Graph),
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	initialize(Graph, SourceID, VerticesIDList, 1, CurrentAccessOfGraph).

%--------- ABBRUCHBEDINGUNG ---------------
initialize(Graph, SourceID, [], Count, AccessOfGraph) -> [Graph, AccessOfGraph];

%----------- INTERNE IMPLEMENTATION ----------------
initialize(Graph, SourceID, VerticesIDList, Count, AccessOfGraph) -> 
	CurrentVertexID = lists:nth(Count, VerticesIDList),
	
	%Den Attribut keiner bei jedem einpflanzen
	ModifyGraph = graph_adt:setValV(CurrentVertexID, predecessor, "empty", Graph),
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	if (CurrentVertexID == SourceID) ->
		   %Zugriff wird eine Zeile unter uns getaetigt
		   initialize(graph_adt:setValV(SourceID, distance, 0, ModifyGraph), SourceID, lists:delete(SourceID, VerticesIDList), Count, incrementAccessOfGraph(CurrentAccessOfGraph));
	true -> 
		   %Zugriff wird eine Zeile unter uns getaetigt
		   initialize(graph_adt:setValV(CurrentVertexID, distance, 576460752303423488, ModifyGraph), SourceID, lists:delete(CurrentVertexID, VerticesIDList), Count, incrementAccessOfGraph(CurrentAccessOfGraph))
	end.

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
calculationPhase(Graph, Count, OverCount, AccessOfGraph) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1
	
	if (Count == EdgeSize + 1) -> 
			controlOfcalculationPhase(Graph, OverCount + 1, AccessOfGraph);
	   true -> 
		   
		   %Zugriff wird eine Zeile unter uns getaetigt
	       CurrentAccessOfGraph_2 = incrementAccessOfGraph(CurrentAccessOfGraph),
		   
			Edge = lists:nth(Count, EdgesD),
	
			%Hier hollen wir uns jetzt u und v und pruefen //Schritt 5
			
			%u VertexID hollen
			UvertexID = erlang:element(1, lists:nth(2, Edge)),

		    %Zugriff wird eine Zeile unter uns getaetigt
	        CurrentAccessOfGraph_3 = incrementAccessOfGraph(CurrentAccessOfGraph_2),
		   
			%Von u die Distance hollen
			Udistance = graph_adt:getValV(UvertexID, distance, Graph),

			%v VertexID hollen
			VvertexID = erlang:element(2 , lists:nth(2, Edge)),

		    %Zugriff wird eine Zeile unter uns getaetigt
	        CurrentAccessOfGraph_4 = incrementAccessOfGraph(CurrentAccessOfGraph_3),
		   
			%Von v die Distance hollen
			Vdistance = graph_adt:getValV(VvertexID, distance, Graph),
		   
		    %Zugriff wird eine Zeile unter uns getaetigt
	        CurrentAccessOfGraph_5 = incrementAccessOfGraph(CurrentAccessOfGraph_4),

			%Gewicht der Kante(u, v) hollen
			Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
			
%06			 wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
			if ( ( (Udistance + (Cost_u_v)) < Vdistance ) ) -> 
				   
				   %Zugriff wird eine Zeile unter uns getaetigt 2x
	        	   CurrentAccessOfGraph_6 = incrementAccessOfGraph(CurrentAccessOfGraph_5),
				   CurrentAccessOfGraph_7 = incrementAccessOfGraph(CurrentAccessOfGraph_6),
				   
				   ModifyGraph = graph_adt:setValV(VvertexID, distance, (Udistance + (Cost_u_v)), Graph),
				   calculationPhase(graph_adt:setValV(VvertexID, predecessor, UvertexID, ModifyGraph), Count + 1, OverCount, CurrentAccessOfGraph_7);
			   true -> calculationPhase(Graph, Count + 1, OverCount, CurrentAccessOfGraph_5)
			end
	end.

%Das ist die Methode von den calculation die aufgerufen wird!
%Dieses noch mal Knotenanzahl -1 mal ausfuehren //Count muss 1 sein!
controlOfcalculationPhase(Graph, OverCount, AccessOfGraph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zugriff wird eine Zeile unter uns getaetigt 2x
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	%Herausfinden wie viele Knoten wir ueberhaupt haben
	VerticesCount = erlang:length(Vertices),
	
	%Hier muss das n erhoeht werden, bis n-1 //Schritt 4
	if (VerticesCount - 1 == OverCount) -> 
		   [Graph, CurrentAccessOfGraph];
	   true -> 
			calculationPhase(Graph, 1, OverCount, CurrentAccessOfGraph)		   
	end.

%------------------------------------------ NEGATIVEN ZYKLUS ERMITTELN ------------------------------------------ 
%10  für jedes (u,v) aus E                
%11      wenn Distanz(u) + Gewicht(u,v) < Distanz(v) dann
%12          STOPP mit Ausgabe "Es gibt einen Zyklus negativen Gewichtes."
%Count muss mit 1 initialisiert werden
%----------- ABBRUCHBEDINGUNG ------------
negativeCircleCheck(Graph, Count, Whatever, AccessOfGraph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1

	if ( EdgeSize + 1 == Count ) -> % + 1, weil index nicht bei null beginnt, sondern bei 1
		   [Graph, CurrentAccessOfGraph];
	   true -> negativeCircleCheck(Graph, Count, AccessOfGraph)
	end.
	
negativeCircleCheck(Graph, Count, AccessOfGraph) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	EdgeSize = erlang:length(EdgesD), % + 1, weil index nicht bei null beginnt, sondern bei 1

	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph_2 = incrementAccessOfGraph(CurrentAccessOfGraph),

	Edge = lists:nth(Count, EdgesD),
			
	%u VertexID hollen
	UvertexID = erlang:element(1, lists:nth(2, Edge)),
			
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph_3 = incrementAccessOfGraph(CurrentAccessOfGraph_2),
	
	%Von u die Distance hollen
	Udistance = graph_adt:getValV(UvertexID, distance, Graph), %getValV funktioniert nicht!
			
	%v VertexID hollen
	VvertexID = erlang:element(2 , lists:nth(2, Edge)),
			
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph_4 = incrementAccessOfGraph(CurrentAccessOfGraph_3),
	
	%Von v die Distance hollen
	Vdistance = graph_adt:getValV(VvertexID, distance, Graph), %funktioniert nicht!
			
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph_5 = incrementAccessOfGraph(CurrentAccessOfGraph_4),
	
	%Gewicht der Kante(u, v) hollen
	Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			
	Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
			
%06			 wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
	if ( (Udistance + Cost_u_v) < Vdistance  ) -> 
			   zyklusNegativerLaengerGefunden;
		true -> negativeCircleCheck(Graph, Count + 1, "", CurrentAccessOfGraph_5) %Abbruchbedingung checken
	end.

% ----------------- HILFSMETHODEN ---------------------
%Methode liefert eine Liste zurueck, an erster Stelle steht der Graph und an zweiter 
%wie oft auf den zugegriffen wurden ist 
addEdgesUInverse(Graph, AccessOfGraph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Zugriff wird eine Zeile unter uns getaetigt
	CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
	
	EdgeSize = erlang:length(EdgesU), % + 1, weil index nicht bei null beginnt, sondern bei 1
	addEdgesUInverse(Graph, 1, EdgeSize, AccessOfGraph).

addEdgesUInverse(Graph, Count, EdgeSize, AccessOfGraph) ->
		{ Vertices, EdgesD, EdgesU } = Graph,
		
	if (Count == EdgeSize + 1) -> 
		   SuperEdge = lists:append(EdgesD, EdgesU),
 		   [{ Vertices, SuperEdge, EdgesU }, AccessOfGraph];
	   true -> 
		   
		   %Zugriff wird eine Zeile unter uns getaetigt
		   CurrentAccessOfGraph = incrementAccessOfGraph(AccessOfGraph),
		   
			Edge = lists:nth(Count, EdgesU),
		   
			%u VertexID hollen
        	UvertexID = erlang:element(1, lists:nth(2, Edge)),
		   
			%v VertexID hollen
			VvertexID = erlang:element(2 , lists:nth(2, Edge)),
		   
			%Kosten aus der Kante hollen
			EdgeCost = lists:nth(2, lists:nth(3, Edge)),
		   
		    %Zugriff wird eine Zeile unter uns getaetigt 2x
		    CurrentAccessOfGraph_2 = incrementAccessOfGraph(CurrentAccessOfGraph),
		    CurrentAccessOfGraph_3 = incrementAccessOfGraph(CurrentAccessOfGraph_2),
		   
			%Umgekehrte Kante hinzufuegen
			ModifyGraph = graph_adt:addEdgeD(VvertexID, UvertexID, Graph),
		   	ModifyGraph_2 = graph_adt:setValE({VvertexID, UvertexID}, cost, EdgeCost, ModifyGraph),
		   
			%rekursiv alle Kanten durch laufen
			addEdgesUInverse(ModifyGraph_2, Count + 1, EdgeSize, CurrentAccessOfGraph_3)
	end.

%Zaehlt um ein hoch
incrementAccessOfGraph(AccsessCount) -> 
	CurrentAccessOfGraph = AccsessCount + 1.