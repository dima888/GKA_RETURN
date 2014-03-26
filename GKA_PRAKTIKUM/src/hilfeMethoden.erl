%% @author Flah
%% @doc @todo Add description to hilfeMethoden.


-module(hilfeMethoden).

%% ====================================================================
%% API functions
%% ====================================================================
-export([getValV/3, getValE/3]).



%% ====================================================================
%% Internal functions
%% ====================================================================
getValE({V_ID1, V_ID2}, Attr, Graph) ->
	nil.

%% Gibt den Wert zu einem Attribut Namen von einem Vertex im Graphen zurück, falls nicht
%% vorhanden, wird nil zurück geliefert
getValV(V_ID, Attr, Graph) ->
	{Vertices, EdgeD, EdgeU} = Graph,
	Attribut = gibAttribut(Vertices, V_ID, []),
	if
		not (Attribut == []) -> gibAttributWert(Attribut);
						true -> nil
	end.

%% Gibt aus der Liste mit Attributnamen und Wert den Wert zurück
gibAttributWert([Attribut]) ->
	[AttrName, AttrValue] = Attribut,
	AttrValue.

%% Sucht nach einem passenden Attribut und gibt den Attribut Namen und Wert in einer Liste
%% zurück, falls nichts gefunden wird, wird eine leere Liste zurück gegeben
gibAttribut([], V_ID, Attribut) ->
	Attribut;
gibAttribut([H|T], V_ID, Attribut) ->
	ID = lists:nth(2, H),
	if
		V_ID == ID -> gibAttribut(T, V_ID, Attribut ++ [[X,Y] || [X,Y] <- H]);
			  true -> gibAttribut(T, V_ID, Attribut)
	end.
	

%%hilfeMethoden:getValV(1, alter, {[[vertex, 2, [alter, 22]], [vertex, 1, [alter, 20]]],[],[]}).
%%cd("/Users/Flah/Dropbox/WorkSpace/GKA_RETURN/GKA_PRAKTIKUM/src").