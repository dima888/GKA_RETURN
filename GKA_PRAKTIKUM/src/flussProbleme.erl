%% @author Flah
%% @doc @todo Add description to flussProbleme.


-module(flussProbleme).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).



%% ====================================================================
%% Internal functions
%% ====================================================================

fordFulkerson(Graph, SourceID, TargetID) ->
	% Schritt 1 - Initialisierung des Flusses mit 0 für jede Kante
	GraphInit = initialisierung(Graph, []),
	
	% Quelle Markieren mit (undefiniert, ∞)
	graph_adt:setValV(SourceID, marked, {"undefiniert", "∞"}, GraphInit).
	
	% Schritt 2 - Inspektion und Markierung
	% Schritt 2A - Falls alle markierten Knoten inspiziert wurden, gehe zu Schritt 4
	
	
	% Schritt 2B - Wähle eine beliebig markierte, aber noch NICHT inspizierte Ecke vi und
	% inspiziere sie wie folgt (Berechnung des Inkrements)
	%	•(Vorwärtskante) Für jede Kante eij € O(vi) mit unmarkierterm Knoten vj und 
	% 	 f(eij) < c(eij) markiere vj mit (+vi, δj), wobei δj die kleinere der beiden Zahlen
	%	 c(eij) - f(eij) und δi ist
	%	•(Rückwärtskante) Für jede Kante eij € I(vi) mit unmarkiertem Knoten vj und
	%	 f(eij) > 0 markiere vj mit (-v, δj), wobei δj die kleinere der beiden Zahlen
	%	 f(eij) und δi ist

	% Schritt 2C - Falls die Senke markiert ist, gehe zu Schritt 3, sonst zu 2A

	% Schritt 3 - Vergößerung der Flußstärke
	% Bei s beginnend lässt sich anhand der Markierungen der gefundene vergrößernde Weg bis
	% zum Knoten q rückwärts durchlaufen. Für jede Vorwärtskante wird f(eij) um δs erhöht und
	% für jede Rückwärtskante wird f(eij) um δs vermindert. Anschließend werden bei allen
	% Knoten mit Ausnahme von q die Markierungen entfernt. Danach wieder zu Schritt 2A

	% Schritt 4 - Es gibt keinen vergrößernden Weg
	% Der jetzige Weg von d ist optimal. Ein Schnitt A(X, Komplement(X)) mit c(X, Komplement(X)) = d
	% wird gebildet von genau denjenigen Kanten, bei denen entweder der Anfangsknoten oder der
	% Endknoten inspiziert ist
	%nil.

% Weißt allen Kanten 0 als initialen Wert für den flow zu
initialisierung({Vertices, EdgesD, EdgesU}, Result) ->
	% Initialisierung
	setAttributsV(setAttributsE({Vertices, EdgesD, EdgesU}, EdgesD), Vertices).

% Setzt bei allen Vertices das Attribut marked mit vorwärtskante / rückwärtskante und Kapazität der Kante
setAttributsV(Graph, []) ->
	Graph;
setAttributsV(Graph, [H|T]) ->
	% ID des Knoten abspeichern
	ID = lists:nth(2, H),
	
	% Jedem Knoten das Attribut marked mit Value {Kantenart, Kapazität} einfügen
	setAttributsV(graph_adt:setValV(ID, marked, {"nil", "nil"}, graph_adt:setValV(ID, inspected, "false", Graph)), T).

% Setzt bei allen maxis Attributen an zweiter Stelle vom Tupel eine 0 ein
setAttributsE(Graph, []) ->
	Graph;
setAttributsE(Graph, [H|T]) ->
	% ID der aktuellen Kante ermitteln
	ID = lists:nth(2, H),
	
	% Wert von is im tupel {max, is} von Attribut maxis auf 0 setzten und max beibehalten
	setAttributsE(graph_adt:setValE(ID, maxis, {element(1, graph_adt:getValE(ID, maxis, Graph)), "0"}, Graph), T).

% cd("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//src").
% flussProbleme:fordFulkerson({[[vertex, 1, [name, "q"]], [vertex, 2, [name, "v1"]], [vertex, 3, [name, "s"]]], [[edgeD, {1,2}, [maxis, {"4","1"}]]], []}, 1, 3).


	