%% @author foxhound
%% @doc @todo Add description to graph_adt.


-module(graph_adt).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new_AlGraph/0, addVertex/2, deleteVertex/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================

%%Erzeugt einen initialen Null Graphen
%%return: Neuer Null Graph
%Struktur des Graphes = { Vertices, EdgesG, EdgesU }
new_AlGraph() -> 
	{ [], {}, {} }.

%Fuegt den Graphen eine neue Ecke mit Indititaet NewItem (V_ID) zu
%NewItem -> Integer
%Graph -> { {}, {}, {} }



addVertex(NewItem, { Vertices, EdgesD, EdgesU }) ->
%----------------- Precondition -------------------- 
BoolValue = lists:member(NewItem, Vertices), %Wert muss zwischen gespeichert werden, zum kotzen!
	if BoolValue -> nil; %Hier waerte schoener explizit zusagen, wo der Fehler ist, ist einfach freundlicher!
	not is_integer(NewItem) -> nil; % Hier genau das gleich wie das Kommentar hier drueber
%----------------- IMPL --------------------
	true -> ModifyGraph = {Vertices ++ [NewItem], EdgesD, EdgesU}
	end.

%Loescht ein Vertex aus den Graphen, zurueck kommt logischerweise ein modifizierter Graph!
deleteVertex(V_Id, { Vertices, EdgesD, EdgesU }) -> 
%----------------- Precondition -------------------- 
BoolValue = lists:member(V_Id, Vertices), %Wert muss zwischen gespeichert werden, zum kotzen!
	if not BoolValue -> nil; %Hier waerte schoener explizit zusagen, wo der Fehler ist, ist einfach freundlicher!
%----------------- IMPL --------------------
	true -> ModifyGraph = {lists:delete(V_Id, Vertices), EdgesD, EdgesU}
	end.



	
	