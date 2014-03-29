%% @author Flah
%% @doc @todo Add description to hilfeMethoden.


-module(hilfeMethoden).

%% ====================================================================
%% API functions
%% ====================================================================
-export([getValV/3, getValE/3, getAttrV/2, getAttrE/2, setValE/4, includeValue/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
%%------------------------------ SELEKTOREN -------------------------------------

%% Gibt den Wert zu einem Attributnamen von einer Edge im Graphen zurück, falls nicht
%% vorhanden wird nil zurück gegeben

getValE({V_ID1, V_ID2}, Attr, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Edges = EdgeD ++ EdgeU,
	Attribut = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
	if
		not (Attribut == []) -> ([A] = Attribut), ([K,V] = A), V;
						true -> nil
	end.

%% Gibt den Wert zu einem Attributnamen von einem Vertex im Graphen zurück, falls nicht
%% vorhanden, wird nil zurück gegeben

getValV(V_ID, Attr, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Attribut = getAttrAndValVertex(Vertices, V_ID, []),
	if
		not (Attribut == []) -> ([A] = Attribut), ([K,V] = A), V;
						true -> nil
	end.

%% Gibt alle verfügbaren Attribute für einen Vertex (V_ID) zurück, falls keiner vorhanden
%% wird eine leere Liste zurück gegeben.

getAttrV(V_ID, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	AttributsAndValues = getAttrAndValVertex(Vertices, V_ID, []),
	Attributs = [lists:nth(1, X) || X <- AttributsAndValues].

%% Gibt alle verfügbaren Attribute für eine Kante ({V_ID1, V_ID2}) zurück, falls keiner
%% vorhanden, wird eine leere Liste zurück gegeben.

getAttrE({V_ID1, V_ID2}, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Edges = EdgeD ++ EdgeU,
	AttributsAndValues = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
	Attributs = [lists:nth(1, X) || X <- AttributsAndValues].

%%----------------------------------- MUTATOREN -----------------------------------------

%% Setzt den Attributwert von Attr auf Val von der Kante im Graphen, wenn nicht vorhanden
%% wird ein Attribut angelegt, sonst verändert

setValE({V_ID1, V_ID2}, Attr, Val, Graph) ->
	{Vertices, EdgesD, EdgesU} = Graph,
	Edges = EdgesD ++ EdgesU,
	
	%Einzelnen Edge aus dem Graphen extrahieren
	EdgeInList = [X || X <- Edges, lists:nth(2, X) == {V_ID1, V_ID2}],
	
	if
		%Prüfen ob überhaupt eine Edge mit der übergebenen ID im Graphen existiert
		EdgeInList == [] -> nil;
					
							%Edge aus der Edgelist extrahieren
					true -> [Edge] = EdgeInList,
							
							%Alle Attribute und Werte extrahieren
							AttributsAndValues = getAttrAndValEdge(Edges, {V_ID1, V_ID2}, []),
							
							%Edgetyp extrahieren
							EdgeType = lists:nth(1, Edge),
							
							%Prüfen um welche Edgeart es sich handelt, da unterschiedliches verhalten
							if
													 %Alle gerichteten Kanten filtern außer die veränderte
								EdgeType == edgeD -> EdgesDNew = [X || X <- EdgesD, lists:nth(2, X) =/= {V_ID1, V_ID2}],
													 if
														%Falls keine Attribute vorhanden sind, einfach das übergebene Attribute und den Wert an die Edge anhängen
														AttributsAndValues == [] -> {Vertices, EdgesDNew ++ [Edge ++ [[Attr, Val]]], EdgesU};
								
														%Falls bereits Attribute vorhanden sind, prüfen ob das übergebene Attribut zu ihnen gehört
														true -> FlattenList = lists:flatten(AttributsAndValues), Included = lists:member(Attr, FlattenList),
																if
																	%Attributwert ersetzten
																	Included == true -> ListWithoutAttr = [[X, Y] || [X, Y] <- Edge, X =/= Attr], 
																			     	{Vertices, EdgesDNew ++ [[EdgeType, {V_ID1, V_ID2}] ++ ListWithoutAttr ++ [[Attr, Val]]], EdgesU};
																			
																				%Attribut und Wert anhängen
															                    true -> EdgeType = lists:nth(1, Edge), EdgeID = lists:nth(2, Edge),
																			     	    {Vertices, EdgesDNew ++ [[EdgeType, {V_ID1, V_ID2}] ++ AttributsAndValues ++ [[Attr, Val]]], EdgesU} 
																end
													 end;
								
													 %Alle ungerichteten Kanten filtern außer die veränderte
								EdgeType == edgeU -> EdgesUNew = [X || X <- EdgesU, ((lists:nth(2, X) =/= {V_ID1, V_ID2}) and (lists:nth(2, X) =/= {V_ID2, V_ID1}))],
													 if
														%Falls keine Attribute vorhanden sind, einfach das übergebene Attribute und den Wert an die Edge anhängen
														AttributsAndValues == [] -> {Vertices, EdgesD, EdgesUNew ++ [Edge ++ [[Attr, Val]]]};
								
														%Falls bereits Attribute vorhanden sind, prüfen ob das übergebene Attribut zu ihnen gehört
														true -> FlattenList = lists:flatten(AttributsAndValues), Included = lists:member(Attr, FlattenList),
																if
																	%Attributwert ersetzten
																	Included == true -> ListWithoutAttr = [[X, Y] || [X, Y] <- Edge, X =/= Attr], 
																			     	{Vertices, EdgesD, EdgesUNew ++ [[EdgeType, {V_ID1, V_ID2}] ++ ListWithoutAttr ++ [[Attr, Val]]]};
																			
																				%Attribut und Wert anhängen
															                    true -> EdgeType = lists:nth(1, Edge), EdgeID = lists:nth(2, Edge),
																			     	    {Vertices, EdgesD, EdgesUNew ++ [[EdgeType, {V_ID1, V_ID2}] ++ AttributsAndValues ++ [[Attr, Val]]]} 
																end
													 end;
								
											 %Fehler, da weder edgeD, noch edgeU
											 true -> nil
							end 
	end.

%% Setzt den Attributwert von Attr auf Val von dem Knoten im Graphen, wenn nicht vorhanden
%% wird ein Attribut angelegt, sonst verändert 

setValV(V_ID, Attr, Val, Graph) ->
	nil.

%%----------------------------- Hilfsmethoden ------------------------------

%% Sucht nach einem passenden Attribut und gibt den Attribut Namen und Wert in einer Liste
%% zurück, falls nichts gefunden wird, wird eine leere Liste zurück gegeben

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
% hilfeMethoden:setValE({1,2}, alter, 20, {[],[[edgeD, {1,2}, [name, hamburg]]],[]}).
% hilfeMethoden:setValE({1,2}, alter, 20, {[],[[edgeD, {1,2}, [alter, 25], [name, hamburg]]],[]}).
% hilfeMethoden:setValE({4,5}, alter, 30, {[],[[edgeD, {1,2}, [alter, 25], [name, hamburg]], [edgeD, {4,5}, [alter, 18]]],[]}).
% hilfeMethoden:setValE({4,5}, alter, 30, {[], [], [[edgeU, {1,2}, [alter, 25], [name, hamburg]], [edgeU, {4,5}, [alter, 18]]]}).

%%cd("/Users/Flah/Dropbox/WorkSpace/GKA_RETURN/GKA_PRAKTIKUM/src").

%hilfeMethoden:includeValue(hamburg ,{[[vertex, 2, [name, hamburg]], [vertex, 7, [name, hannover]]], [], []}).
includeValue(Val, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Attributs = getAttrAndValVertex(Vertices, []),
	Value = [X || X <- Attributs, lists:nth(2, X) == Val],
	
	if
		Value == [] -> false;
			   true -> true
	end.

getAttrAndValVertex([], Attribut) ->
	Attribut;
getAttrAndValVertex([H|T],  Attribut) ->
	getAttrAndValVertex(T, Attribut ++ [[X,Y] || [X,Y] <- H]).