%% @author foxhound
%% @doc @todo Add description to graph_adt.


-module(graph_adt).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new_AlGraph/0, addVertex/2, deleteVertex/2, addEdgeU/3, addEdgeD/3, deleteEdge/3]).



%% ====================================================================
%% Internal functions
%% ====================================================================

%%Erzeugt einen initialen Null Graphen
%%return: Neuer Null Graph
%Struktur des Graphes = { Vertices, EdgesG, EdgesU }
new_AlGraph() -> 
	{ [], [], [] }.

%---------------- METHODE ---------------------
%Fuegt den Graphen eine neue Ecke mit Indititaet NewItem (V_ID) zu
%NewItem -> Integer
%Graph -> { [], [], [] }
addVertex(NewItem, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
BoolValue = lists:member(NewItem, Vertices), %Wert muss zwischen gespeichert werden, zum kotzen!
VertexList = [ lists:nth(2, X) || X <- Vertices],
BoolDoubleVertex = lists:member(NewItem, VertexList),
	
	if BoolValue -> nil; %Hier waerte schoener explizit zusagen, wo der Fehler ist, ist einfach freundlicher!
	BoolDoubleVertex -> nil;
	not is_integer(NewItem) -> nil; % Hier genau das gleich wie das Kommentar hier drueber
%----------------- IMPL --------------------
	true -> ModifyGraph = {Vertices ++ [[vertex, NewItem]], EdgesD, EdgesU}
	end.

%---------------- METHODE ---------------------
%Loescht ein Vertex aus den Graphen, zurueck kommt logischerweise ein modifizierter Graph!
%TODO: Alle Kanten muessen auch geloescht werden, die da dran haengen!!!!
deleteVertex(V_ID, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
VertexList = [ lists:nth(2, X) || X <- Vertices], %Alle Vertex IDs
BoolDoubleVertex = lists:member(V_ID, VertexList),

%----------------- IMPL --------------------	
ModifyVertexList = [ X || X <- Vertices, lists:nth(2, X) =/= V_ID],
	if not BoolDoubleVertex-> nil; %Hier waerte schoener explizit zusagen, wo der Fehler ist, ist einfach freundlicher!
	true ->
		%Wir loeschen alle Kanten, die an den Vertex haengen
ModifyEdgesD  = [ X || X <- EdgesD, ( element(1, lists:nth(2, X)) =/= V_ID ) and ( element(2, lists:nth(2, X)) =/= V_ID )],
ModifyEdgesU  = [ X || X <- EdgesD, ( element(1, lists:nth(2, X)) =/= V_ID ) and ( element(2, lists:nth(2, X)) =/= V_ID )],
		ModifyGraph = {ModifyVertexList, ModifyEdgesD, ModifyEdgesU}
	end.

%---------------- METHODE ---------------------
% Zurzeit sind noch zwei mal die gleichen Kanten zwischen Zwei Knoten erlaubt
addEdgeU(V_ID1, V_ID2, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
%Es muss geprueft werden, ob die IDs ueberhhaupt im Graf vorhanden sind
	VertexList = [ lists:nth(2, X) || X <- Vertices],
	Bool_V_ID1 = lists:member(V_ID1, VertexList),
	Bool_V_ID2 = lists:member(V_ID2, VertexList),
	
	
%Normalerweise muesste auch das gleiche noch mal fuer EdgeD geprueft werden	

if (not (Bool_V_ID1 and Bool_V_ID2)) -> nil;
	true -> { Vertices, EdgesD, ModifyEdgeU = EdgesU ++ [[edgeU, {V_ID1, V_ID2}] ] }
end.

%---------------- METHODE ---------------------
% Zurzeit sind noch zwei mal die gleichen Kanten zwischen Zwei Knoten erlaubt
addEdgeD(V_ID1, V_ID2, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
%Es wird geprueft werden, ob die IDs ueberhhaupt im Graf vorhanden sind
	VertexList = [ lists:nth(2, X) || X <- Vertices],
	Bool_V_ID1 = lists:member(V_ID1, VertexList),
	Bool_V_ID2 = lists:member(V_ID2, VertexList),
	
	
%Normalerweise muesste auch das gleiche noch mal fuer EdgeD geprueft werden	
if (not (Bool_V_ID1 and Bool_V_ID2)) -> nil;
	true -> { Vertices, ModifyEdgeD = EdgesD ++ [[edgeD, {V_ID1, V_ID2}] ], EdgesU }
end.

%---------------- METHODE ---------------------
%TODO: Soll ungerichtete Kante loeschen, egal wie rum die reinfolge der IDs rein gegeben wird
deleteEdge(V_ID1, V_ID2, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	
	%%Loeschen der Kanten findet hier stat
	DelEdgeDList = [ X || X <- EdgesD, ( element(1, lists:nth(2, X)) =/= V_ID1 ) or ( element(2, lists:nth(2, X)) =/= V_ID2 )],
	DelEdgeUList = [ X || X <- EdgesU, ( element(1, lists:nth(2, X)) =/= V_ID1 ) or ( element(2, lists:nth(2, X)) =/= V_ID2 )],

	%%---- Precondition ---- > Gib nil zurueck, wenn nichts geloescht wird
	if ( ( length(DelEdgeDList) == length(EdgesD) ) and ( length(DelEdgeUList) == length(EdgesU) ) ) or ( ( length(EdgesD) == 0) and ( length(EdgesU) == 0 ) )  -> nil;
	true -> { Vertices, DelEdgeDList, DelEdgeUList }
	end.
	
	

	%%------------------------Test Werte--------------------------------
	%G1 = graph_adt:addVertex(1, graph_adt:new_AlGraph()).
	%G2 = graph_adt:addVertex(2, G1).
	%G3 = graph_adt:addEdgeD(1, 2, G2).
	%G4 = graph_adt:addVertex(3, G3).
	%G5 = graph_adt:addEdgeD(1, 3, G4). 
	%G6 = graph_adt:addEdgeU(1, 3, G5).
	%G7 = graph_adt:deleteEdge(1, 2, G6).
	%TestGraph = {[[vertex,1],[vertex,2],[vertex,3]], [[edgeD,{1,2}],[edgeD,{1,3}]], [[edgeU,{1,3}]]}
