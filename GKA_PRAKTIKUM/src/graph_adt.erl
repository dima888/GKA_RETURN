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







	
	