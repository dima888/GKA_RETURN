%% @author Flah
%% @doc @todo Add description to hilfeMethoden.


-module(hilfeMethoden).

%% ====================================================================
%% API functions
%% ====================================================================
-export([getValV/3, getValE/3, getAttrV/2, getAttrE/2, setValE/4]).



%% ====================================================================
%% Internal functions
%% ====================================================================
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

%%-----------------------------------MUTATOREN-----------------------------------------

%% Setzt den Attributwert von Attr auf Val von der Kante im Graphen, wenn nicht vorhanden
%% wird ein Attribut angelegt, sonst ver�ndert

setValE({V_ID1, V_ID2}, Attr, Val, Graph) ->
	{Vertices, EdgesD, EdgesU} = Graph,
	EdgeInList = [X || X <- EdgesD, (element(1, lists:nth(2, X))) == V_ID1],
	[Edge] = EdgeInList,
	Edges = EdgesD ++ EdgesU,
	AttributsAndValues = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
	if
		AttributsAndValues == [] -> {Vertices, [Edge ++ [[Attr, Val]]], EdgesU};
							true -> io:fwrite("Fick die Welt!")
	end.

%% Setzt den Attributwert von Attr auf Val von dem Knoten im Graphen, wenn nicht vorhanden
%% wird ein Attribut angelegt, sonst ver�ndert

setValV(V_ID, Attr, Val, Graph) ->
	nil.

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

%%*** setValE ***
% hilfeMethoden:setValE({1,2}, alter, 20, {[],[[edgeD, {1,2}]],[]}).

%%cd("/Users/Flah/Dropbox/WorkSpace/GKA_RETURN/GKA_PRAKTIKUM/src").