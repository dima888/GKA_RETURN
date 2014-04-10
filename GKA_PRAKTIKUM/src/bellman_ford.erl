%% @author foxhound
%% @doc @todo Add description to 'Bellman_Ford'.
%09.04.14 -> 3std
%10.04.14 -> 3std

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


%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
algoStepTwo(Graph, Count) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	EdgeSize = erlang:length(EdgesU)+1, % + 1, weil index nicht bei null beginnt, sondern bei 1
	
	if (Count == EdgeSize) -> 
		   fertig; %Hier muss das n erhoeht werden, bis n-1 //Schritt 4
	   true -> 
			Edge = lists:nth(Count, EdgesU),
			%Hier hollen wir uns jetzt u und v und pruefen //Schritt 5
			
			%u VertexID hollen
			UvertexID = erlang:element(1, lists:nth(2, Edge)),
			
			%Von u die Distance hollen
			%Udistance = graph_adt:getValV(UvertexID, distance, Graph), %getValV funktioniert nicht!
			

			%v VertexID hollen
			VvertexID = erlang:element(2, lists:nth(2, Edge)),
			
			%Von v die Distance hollen
			%Vdistance = graph_adt:getValV(VvertexID, distance, Graph), %funktioniert nicht!

			%Gewicht der Kante(u, v) hollen
			Cost_u_v_inStringList = graph_adt:getValE({UvertexID, VvertexID}, cost, Graph),
			Cost_u_v = erlang:list_to_integer(Cost_u_v_inStringList),
	
			%wenn Distanz(u) + Gewicht(u,v) < Distanz(v)

			
			%Testbox return, damit ich schlafen gehen kann
			[Cost_u_v]
	end.

	%VvertexID_2 = erlang:element(2, lists:nth(2, EdgesD)),
	

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost"). 
%L = bellman_ford:initialize(Graph, 1).
%bellman_ford:algoStepTwo(L, 1).
















% ----------------- HILFSMETHODEN --------------------- 
setAttributsV(Graph, []) -> Graph;
setAttributsV(Graph, [H|T]) ->
	% ID des Knoten abspeichern
 	ID = lists:nth(2, H), 
	setAttributsV(graph_adt:setValV(ID, distance, 0, Graph), T).
	


