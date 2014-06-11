% cd("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//src").
% c(fordFulkerson).
% G = graph_parser:importGraph("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//Dokumentation//grbuch.txt", "maxis").
% G1 = fordFulkerson:fordFulkerson(G).

-module(fordFulkerson).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

fordFulkerson(Graph) ->
	% initialisierungPrivat durchführen und zu Schritt 2 gehen
	InitGraphAndCount = initialisierung(Graph, 0),
	findFlowPath(element(1, InitGraphAndCount), element(2, InitGraphAndCount)).

% Schritt 1 - initialisierungPrivat des Flusses mit 0 für jede Kante
% Quelle q Markieren mit (undefiniert, ∞)
initialisierung(Graph, Counter) -> 
	SourceVertex = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	{graph_adt:setValV(lists:nth(2, lists:nth(1, SourceVertex)), marked, {"undefined", "100000"}, initialisierungPrivat(Graph, [])), Counter + 2}.

% Schritt 2 - Inspektion und Markierung
findFlowPath(Graph, Counter) ->
	% Schritt 2A - Falls alle markierten Knoten inspiziert wurden, gehe zu Schritt 4
	AllMarkedVerticesInspectedAndCounter = areAllMarkedVerticesInspected(Graph, element(1, Graph), [], Counter),
	AllMarkedVerticesInspected = element(1, AllMarkedVerticesInspectedAndCounter),
	NewCounter = element(2, AllMarkedVerticesInspectedAndCounter),
	
	if
		 AllMarkedVerticesInspected == true -> minCut(Graph, Counter); % Springe zu Schritt 4
			   						   true -> % Schritt 2B - Wähle eine beliebig markierte, aber noch NICHT inspizierte Ecke vi und
											   % inspiziere sie wie folgt (Berechnung des Inkrements)
											   %	•(Vorwärtskante) Für jede Kante eij € O(vi) mit unmarkierterm Knoten vj und 
											   % 	 f(eij) < c(eij) markiere vj mit (+vi, δj), wobei δj die kleinere der beiden Zahlen
											   %	 c(eij) - f(eij) und δi ist
											   %	•(Rückwärtskante) Für jede Kante eij € I(vi) mit unmarkiertem Knoten vj und
											   %	 f(eij) > 0 markiere vj mit (-vi, δj), wobei δj die kleinere der beiden Zahlen
											   %	 f(eij) und δi ist
											   
											   %io:nl(), io:fwrite("Vor dem markieren!"), io:nl(),
											   %print(Graph),
											   %timer:sleep(1000),
											   AlleMarkedVertices = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), marked, Graph) =/= {"nil", "nil"}) and (graph_adt:getValV(lists:nth(2, X), inspected, Graph) == "false")],
											   ArbitraryMarkedVertex = lists:nth(1, AlleMarkedVertices),
											   NewMarkedGraphAndCounter = forwardEdges(ArbitraryMarkedVertex, graph_adt:setValV(lists:nth(2, ArbitraryMarkedVertex), inspected, "true", Graph), NewCounter),
											   NewMarkedGraph = element(1, NewMarkedGraphAndCounter),
											   NewCounter1 = element(2, NewMarkedGraphAndCounter),
											   NewMarkedGraph1AndCounter = backwardEdges(ArbitraryMarkedVertex, graph_adt:setValV(lists:nth(2, ArbitraryMarkedVertex), inspected, "true", NewMarkedGraph), NewCounter1),
											   NewMarkedGraph1 = element(1, NewMarkedGraph1AndCounter),
											   NewCounter2 = element(2, NewMarkedGraph1AndCounter),
											   %io:nl(), io:fwrite("Nach dem markieren!"), io:nl(),
											   %print(NewMarkedGraph),
											   %timer:sleep(1000),

											   % Schritt 2C - Falls die Senke markiert ist, gehe zu Schritt 3, sonst zu 2A
											   Target = [X || X <- element(1, NewMarkedGraph1), graph_adt:getValV(lists:nth(2, X), name, NewMarkedGraph1) == "s"],
											   TargetMarked = graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, NewMarkedGraph1),

											   if
													TargetMarked =/= {"nil", "nil"} -> raiseFlow(NewMarkedGraph1, NewCounter2 + length(element(1, NewMarkedGraph1)) + 1); % gehe zu Schritt 3
						  											 		   true -> findFlowPath(NewMarkedGraph1, NewCounter2 + length(element(1, NewMarkedGraph1)) + 1)  % gehe zu Schritt 2A
											   end
	end.

% Schritt 3 - Vergößerung der Flußstärke
raiseFlow(Graph, Counter) ->
	% Bei s beginnend lässt sich anhand der Markierungen der gefundene vergrößernde Weg bis
	% zum Knoten q rückwärts durchlaufen. Für jede Vorwärtskante wird f(eij) um δs erhöht und
	% für jede Rückwärtskante wird f(eij) um δs vermindert. Anschließend werden bei allen
	% Knoten mit Ausnahme von q die Markierungen entfernt. Danach wieder zu Schritt 2A
	
	%io:fwrite("------- SCHRITT 3 ---------"),
	Target = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "s"],
	FoundPathAndCounter = findPath([Target], Graph, Counter),
	FoundPath = element(1, FoundPathAndCounter),
	NewCounter = element(2, FoundPathAndCounter),
	ReversedPath = lists:reverse(FoundPath),
	NewFlowAndCounter = raiseFlowPrivat(ReversedPath, Graph, NewCounter),
	NewFlow = element(1, NewFlowAndCounter),
	NewCounter1 = element(2, NewFlowAndCounter),
	ResetAndCounter = resetMarksAndInspected(element(1, NewFlow), NewFlow, NewCounter1),
	ResetedGraph = element(1, ResetAndCounter),
	NewCounter2 = element(2, ResetAndCounter),
	findFlowPath(ResetedGraph, NewCounter2).

% Schritt 4 - Es gibt keinen vergrößernden Weg
minCut(Graph, Counter) ->
	% Der jetzige Weg von d ist optimal. Ein Schnitt A(X, Komplement(X)) mit c(X, Komplement(X)) = d
	% wird gebildet von genau denjenigen Kanten, bei denen entweder der Anfangsknoten oder der
	% Endknoten inspiziert ist
	
	%io:fwrite("------- SCHRITT 4 ---------\n"),
	Source = lists:nth(1, [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"]),
	SourceAdjacentVertices = graph_adt:getAdjacent(lists:nth(2, Source), Graph),
	SourceAdjacentVerticesIDs = [element(2, X) || X <- SourceAdjacentVertices],
	SourceEdges = [X || X <- element(2, Graph), Y <- SourceAdjacentVerticesIDs, lists:nth(2, X) == {lists:nth(2, Source), Y}],
	Flows = [list_to_integer(element(2, graph_adt:getValE(lists:nth(2, X), maxis, Graph))) || X <- SourceEdges],
	MaximumFlow = lists:sum(Flows),
	io:nl(),
	io:fwrite("MaximumFlow: "), io:write(MaximumFlow), io:nl(), io:nl(),
	io:fwrite("Graph-Zugriffe: "), io:write(Counter), io:nl(), io:nl(),
	Graph.
%%================================================================================================================
%% 												HILFSMETHODEN	
%%================================================================================================================

% Weißt allen Kanten 0 als initialen Wert für den flow zu
initialisierungPrivat({Vertices, EdgesD, EdgesU}, Result) ->
	% initialisierungPrivat
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

% Gibt ein Boolean zurück, ob alle markierten Knoten auch inspiziert wurden
areAllMarkedVerticesInspected(Graph, [], BoolList, Counter) ->
	% Rückgabewert true, wenn alle markierten Knoten auch inspiziert, sonst false
	FalseIncluded = lists:member(false, BoolList),

	if
		(not FalseIncluded) == true -> {true, Counter};
				     		   true -> {false, Counter}
	end;
areAllMarkedVerticesInspected(Graph, [H|T], BoolList, Counter) ->
	% Markierte Knoten ausfindig machen
	MarkedValue = graph_adt:getValV(lists:nth(2, H), marked, Graph),

	if
		% Falls Knoten markiert, prüfe ob auch inspiziert
		MarkedValue =/= {"nil", "nil"} -> CheckWithCount = checkIfInspected(Graph, H, Counter),
										  Check = [element(1, CheckWithCount)],
										  NewCounter = element(2, CheckWithCount),
										  areAllMarkedVerticesInspected(Graph, T, BoolList ++ Check, NewCounter + 1);

								  % Falls nicht, prüfe nächsten Knoten
					   			  true -> areAllMarkedVerticesInspected(Graph, T, BoolList, Counter + 1)
	end.

% Prüft ob ein Vertex inspiziert wurde
checkIfInspected(Graph, Vertex, Counter) ->
	Inspected = graph_adt:getValV(lists:nth(2, Vertex), inspected, Graph),

	if
		Inspected == "true" -> {true, Counter + 1};
					   true -> {false, Counter + 1}
	end.

% Führt den Schritt der Markierung für die Vorwärtskanten durch
%	•(Vorwärtskante) Für jede Kante eij € O(vi) mit unmarkierterm Knoten vj und 
% 	 f(eij) < c(eij) markiere vj mit (+vi, δj), wobei δj die kleinere der beiden Zahlen
%	 c(eij) - f(eij) und δi ist
forwardEdges(ArbitraryMarkedVertex, Graph, Counter) ->
	ID = lists:nth(2, ArbitraryMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	ForwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == t) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	ForwardVertices = [X || X <- element(1, Graph), Y <- ForwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	%ForwardVerticesWithFreeSpace = [X || X <- ForwardVertices, list_to_integer(element(1, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph))) > list_to_integer(element(2, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph)))],
	Result = markForwardVertices(ArbitraryMarkedVertex, ForwardVertices, Graph, Counter  + length(AdjacentVertices)),
	{element(1, Result), element(2, Result)}.

% Führt den Schritt der Markierung für die Rückwärtskanten durch
%	•(Rückwärtskante) Für jede Kante eij € I(vi) mit unmarkiertem Knoten vj und
%	 f(eij) > 0 markiere vj mit (-v, δj), wobei δj die kleinere der beiden Zahlen
%	 f(eij) und δi ist
backwardEdges(ArbitraryMarkedVertex, Graph, Counter) ->
	ID = lists:nth(2, ArbitraryMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	BackwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == s) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	BackwardVertices = [X || X <- element(1, Graph), Y <- BackwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	%io:fwrite("BackwardVertices: "), erlang:display(BackwardVertices),
	%BackwardVerticesWithFreeSpace = [X || X <- BackwardVertices, (list_to_integer(element(2, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph)) > 0))],
	Result = markBackwardVertices(ArbitraryMarkedVertex, BackwardVertices, Graph, Counter + length(AdjacentVertices)),
	{element(1, Result), element(2, Result)}.

% Markiert die Vertices für die die Bedingungen zu treffen aus forwardEdges
markForwardVertices(ArbitraryMarkedVertex, [], Graph, Counter) ->
	{Graph, Counter};
markForwardVertices(ArbitraryMarkedVertex, [H|T], Graph, Counter) ->
	Maxis = graph_adt:getValE({lists:nth(2, ArbitraryMarkedVertex), lists:nth(2, H)}, maxis, Graph),
	Capacity = element(1, Maxis),
	Flow = element(2, Maxis),

	if
		Capacity > Flow -> markForwardVertices(ArbitraryMarkedVertex, T, graph_adt:setValV(lists:nth(2, H), marked, {"+" ++ graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(1, graph_adt:getValE({lists:nth(2, ArbitraryMarkedVertex), lists:nth(2, H)}, maxis, Graph))) - list_to_integer(element(2, graph_adt:getValE({lists:nth(2, ArbitraryMarkedVertex), lists:nth(2, H)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), marked, Graph)))))}, Graph), Counter + 6);
				   true -> markForwardVertices(ArbitraryMarkedVertex, T, Graph, Counter)
	end.

% Markiert die Vertices für die die Bedingungen zu treffen aus backwardEdges
markBackwardVertices(ArbitraryMarkedVertex, [], Graph, Counter) ->
	{Graph, Counter};
markBackwardVertices(ArbitraryMarkedVertex, [H|T], Graph, Counter) ->
	Maxis = graph_adt:getValE({lists:nth(2, H), lists:nth(2, ArbitraryMarkedVertex)}, maxis, Graph),
	%io:fwrite("Maxis: "), erlang:display(Maxis), io:nl(),
	Flow = list_to_integer(element(2, Maxis)),

	if
		Flow > 0 -> markBackwardVertices(ArbitraryMarkedVertex, T, graph_adt:setValV(lists:nth(2, H), marked, {"-" ++ graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(2, graph_adt:getValE({lists:nth(2, H), lists:nth(2, ArbitraryMarkedVertex)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), marked, Graph)))))}, Graph), Counter + 5);
			true -> markBackwardVertices(ArbitraryMarkedVertex, T, Graph, Counter)
	end.

% Sucht vom Target den Weg Rückwärts zurück zum Source und gibt eine Liste zurück mit den Vertices
findPath(Result, Graph, Counter) ->
	Vertex = lists:nth(1, Result),
	Predecessor = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), name, Graph) == (lists:nthtail(1, element(1, graph_adt:getValV(lists:nth(2, lists:nth(1, Vertex)), marked, Graph)))))],
	if
		Predecessor == [] -> {Result, Counter + 2};
					 true -> findPath([Predecessor] ++ Result, Graph, Counter + 2)
	end.

% Setzt für die Kanten den neuen tatsächlichen Fluss Rückwärts beginnend beim Target auf den Wert des Flusses vom Target (s)
% Für jede Vorwärtskante wird f(eij) um δs erhöht und
% für jede Rückwärtskante wird f(eij) um δs vermindert. 
raiseFlowPrivat([], Graph, Counter) ->
	{Graph, Counter};
raiseFlowPrivat([H|T], Graph, Counter) ->
	Forward = 43, % Steht für + in Dezimal für ASCII
	Backward = 45, % Steht für - in Dezimal für ASCII
	Target = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "s"],
	TargetFlowAsInt = list_to_integer(element(2, graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, Graph))),
	AttrMarkedValue = graph_adt:getValV(lists:nth(2, lists:nth(1, H)), marked, Graph),
	Predecessor = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == lists:nthtail(1, element(1, AttrMarkedValue))],
	if
		Predecessor == [] -> raiseFlowPrivat(T, Graph, Counter + 4);
					 true -> ForwardOrBackward = lists:nth(1, element(1, AttrMarkedValue)),
							 IDPredecessor = lists:nth(2, lists:nth(1, Predecessor)),
							 ID = lists:nth(2, lists:nth(1, H)),
							 if
		 						 ForwardOrBackward == Forward -> raiseFlowPrivat(T, graph_adt:setValE({IDPredecessor, ID}, maxis, {element(1, graph_adt:getValE({IDPredecessor, ID}, maxis, Graph)), integer_to_list((list_to_integer((element(2, graph_adt:getValE({IDPredecessor, ID}, maxis, Graph)))) + TargetFlowAsInt))}, Graph), Counter + 7);
								ForwardOrBackward == Backward -> raiseFlowPrivat(T, graph_adt:setValE({ID, IDPredecessor}, maxis, {element(1, graph_adt:getValE({ID, IDPredecessor}, maxis, Graph)), integer_to_list(list_to_integer(element(2, graph_adt:getValE({ID, IDPredecessor}, maxis, Graph))) - TargetFlowAsInt)}, Graph), Counter + 7);
														 true -> io:fwrite("WEDER + noch - !!!!!!!!")
							 end
	end.

% Entfertn alle Markierungen, bis auf die des Source Vertexes (q)
resetMarksAndInspected([], Graph, Counter) ->
	{Graph, Counter};
resetMarksAndInspected([H|T], Graph, Counter) ->
	VertexName = graph_adt:getValV(lists:nth(2, H), name, Graph),
	if
		VertexName =/= "q" -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), marked, {"nil", "nil"}, (graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))), Counter + 3);
					  true -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph), Counter + 2)
	end.

% Zeigt den Graphen an
print({Vertices, EdgesD, EdgesU}) ->
	io:nl(), io:fwrite("------------- Vertices -------------"), io:nl(),
	printAll(Vertices),

	io:fwrite("------------- EdgesD -------------"), io:nl(),
	printAll(EdgesD).

	% io:fwrite("------------- EdgesU -------------"), io:nl(),
	% printAll(EdgesU).

printAll([]) ->
	io:nl();
printAll([H|T]) ->
	erlang:display(H), io:nl(),
	printAll(T).