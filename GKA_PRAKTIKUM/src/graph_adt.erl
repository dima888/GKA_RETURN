%% @author foxhound
%% @doc @todo Add description to graph_adt.


-module(graph_adt).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new_AlGraph/0, addVertex/2, deleteVertex/2, addEdgeU/3]).



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
deleteVertex(V_ID, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
VertexList = [ lists:nth(2, X) || X <- Vertices], %Alle Vertex IDs
BoolDoubleVertex = lists:member(V_ID, VertexList),

%----------------- IMPL --------------------
ModifyVertexList = [ X || X <- Vertices, lists:nth(2, X) =/= V_ID],
	if not BoolDoubleVertex-> nil; %Hier waerte schoener explizit zusagen, wo der Fehler ist, ist einfach freundlicher!
	true -> ModifyGraph = {ModifyVertexList, EdgesD, EdgesU}
	end.

%---------------- METHODE ---------------------
addEdgeU(V_ID1, V_ID2, Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
%----------------- Precondition -------------------- 
%Es muss geprueft werden, ob die IDs ueberhhaupt im Graf vorhanden sind
	VertexList = [ lists:nth(2, X) || X <- Vertices],
	Bool_V_ID1 = lists:member(V_ID1, VertexList),
	Bool_V_ID2 = lists:member(V_ID2, VertexList),
	
%Hier wird geprueft, dass Doppelte Kanten nicht erlaubt werden	
	EdgeUtupleInList = [ erlang:tuple_to_list(X) || X <- EdgesU],
	BoolList = [ lists:member(V_ID1, X) and lists:member(V_ID2, X) || X <- EdgeUtupleInList],
	BoolValue = lists:member(true, BoolList),	

if (not (Bool_V_ID1 and Bool_V_ID2)) -> nil;
   BoolValue -> nil;
	true -> { Vertices, EdgesD, ModifyEdgeU = EdgesU ++ [{V_ID1, V_ID2}] }
end.

%%------------------------------ SELEKTOREN -------------------------------------

%% Gibt den Wert zu einem Attributnamen von einer Edge im Graphen zur�ck, falls nicht
%% vorhanden wird nil zur�ck gegeben

getValE({V_ID1, V_ID2}, Attr, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Edges = EdgeD ++ EdgeU,
	Attribut = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
	if
		not (Attribut == []) -> ([A] = Attribut), ([K,V] = A), V;
						true -> nil
	end.

%% Gibt den Wert zu einem Attributnamen von einem Vertex im Graphen zur�ck, falls nicht
%% vorhanden, wird nil zur�ck gegeben

getValV(V_ID, Attr, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Attribut = getAttrAndValVertex(Vertices, V_ID, []),
	if
		not (Attribut == []) -> ([A] = Attribut), ([K,V] = A), V;
						true -> nil
	end.

%% Gibt alle verf�gbaren Attribute f�r einen Vertex (V_ID) zur�ck, falls keiner vorhanden
%% wird eine leere Liste zur�ck gegeben.

getAttrV(V_ID, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	AttributsAndValues = getAttrAndValVertex(Vertices, V_ID, []),
	Attributs = [lists:nth(1, X) || X <- AttributsAndValues].

%% Gibt alle verf�gbaren Attribute f�r eine Kante ({V_ID1, V_ID2}) zur�ck, falls keiner
%% vorhanden, wird eine leere Liste zur�ck gegeben.

getAttrE({V_ID1, V_ID2}, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Edges = EdgeD ++ EdgeU,
	AttributsAndValues = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
	Attributs = [lists:nth(1, X) || X <- AttributsAndValues].

%%----------------------------- Hilfsmethoden ------------------------------

%% Sucht nach einem passenden Attribut und gibt den Attribut Namen und Wert in einer Liste
%% zur�ck, falls nichts gefunden wird, wird eine leere Liste zur�ck gegeben

getAttrAndValVertex([], V_ID, Attribut) ->
	Attribut;
getAttrAndValVertex([H|T], V_ID, Attribut) ->
	ID = lists:nth(2, H),
	if
		V_ID == ID -> getAttrAndValVertex(T, V_ID, Attribut ++ [[X,Y] || [X,Y] <- H]);
			  true -> getAttrAndValVertex(T, V_ID, Attribut)
	end.


getAttrAndValEdge([], E_ID, Attribut) ->
	Attribut;
getAttrAndValEdge([H|T], E_ID, Attribut) ->
	ID = lists:nth(2, H),
	if
		E_ID == ID -> getAttrAndValEdge(T, E_ID, Attribut ++ [[X, Y] || [X, Y] <- H]);
			  true -> getAttrAndValEdge(T, E_ID, Attribut)
	end.

%%------------------------------------ TESTS ------------------------------------------

%%*** getValE ***
% hilfeMethoden:getValE({1,2}, alter, {[],[[edgeD, {1,2}, [alter, 22]]],[]}).
% hilfeMethoden:getValE({1,2}, alter, {[],[[edgeD, {1,2}, [alter, 22]]],[[edgeU, {1,2}, [alter, 20]]]}).

%%*** getValV ***
% hilfeMethoden:getValV(1, alter, {[[vertex, 2, [alter, 22]], [vertex, 1, [alter, 20]]],[],[]}).

%%*** getAttrV ***
% hilfeMethoden:getAttrV(1, {[[vertex, 1, [alter, 20], [b, 4], [name, hamburg]]],[],[]}).

%%*** getAttrE ***
% hilfeMethoden:getAttrE({1,2}, {[],[[edgeD, {1,2}, [alter, 22], [name, hamburg]]],[]}). 
% hilfeMethoden:getAttrE({1,2}, {[],[[edgeD, {1,2}, [alter, 22], [name, hamburg]]],[[edgeU, {1,2}, [strasse, kroonhorst]]]}).





	
	