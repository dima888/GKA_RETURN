%% @author foxhound
%% @doc @todo Add description to 'Bellman_Ford'.

%Quelle: http://de.wikipedia.org/wiki/Bellman-Ford-Algorithmus
%Quelle: http://fuzzy.cs.uni-magdeburg.de/studium/graph/txt/duvigneau.pdf
%01  für jedes v aus V                   
%02      Distanz(v) := unendlich, Vorgänger(v) := keiner
%03  Distanz(s) := 0

%04  wiederhole n - 1 mal               
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
%04  wiederhole n - 1 mal               
%05      für jedes (u,v) aus E
%06          wenn Distanz(u) + Gewicht(u,v) < Distanz(v)
%07          dann
%08              Distanz(v) := Distanz(u) + Gewicht(u,v)
%09              Vorgänger(v) := u
algoStepTwo(Graph, Count) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	Edge = lists:nth(1, EdgesD),
	%VvertexID_2 = erlang:element(2, lists:nth(2, EdgesD)),
	X = 4.
	



















% ----------------- HILFSMETHODEN --------------------- 
setAttributsV(Graph, []) -> Graph;
setAttributsV(Graph, [H|T]) ->
	% ID des Knoten abspeichern
 	ID = lists:nth(2, H), 
	setAttributsV(graph_adt:setValV(ID, distance, 0, Graph), T).
	


