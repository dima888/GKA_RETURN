% cd("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//src").
% c(edmondsKarp).
% G = graph_parser:importGraph("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//Dokumentation//fhwedel.txt", "maxis").
% G1 = edmondsKarp:edmondsKarp(G).

-module(edmondsKarp).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

edmondsKarp(Graph) ->
	% Initialisierung durchführen und zu Schritt 2 gehen
	step2(element(1, step1(Graph)), element(2, step1(Graph))).

% Schritt 1 - Initialisierung des Flusses mit 0 für jede Kante
% Quelle q Markieren mit (undefiniert, ∞)
step1(Graph) -> 
	SourceVertex = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	NewQueue = queue:new(),
	NewGraph = graph_adt:setValV(lists:nth(2, lists:nth(1, SourceVertex)), marked, {"undefined", "100000"}, initialisierung(Graph, [])),
	SourceVertexModified = [X || X <- element(1, NewGraph), graph_adt:getValV(lists:nth(2, X), name, NewGraph) == "q"],
	{NewGraph, queue:in(SourceVertexModified, NewQueue)}.


% Schritt 2 - Inspektion und Markierung
step2(Graph, Queue) ->
	% Schritt 2A - Falls alle markierten Knoten inspiziert wurden, gehe zu Schritt 4
	AllMarkedVerticesInspected = areAllMarkedVerticesInspected(Graph, element(1, Graph), []),
	
	if
		 AllMarkedVerticesInspected == true -> step4(Graph); % Springe zu Schritt 4
			   						   true -> % Schritt 2B - Wähle die ältest markierte, aber noch NICHT inspizierte Ecke vi und
											   % inspiziere sie wie folgt (Berechnung des Inkrements)
											   %	•(Vorwärtskante) Für jede Kante eij € O(vi) mit unmarkierterm Knoten vj und 
											   % 	 f(eij) < c(eij) markiere vj mit (+vi, δj), wobei δj die kleinere der beiden Zahlen
											   %	 c(eij) - f(eij) und δi ist
											   %	•(Rückwärtskante) Für jede Kante eij € I(vi) mit unmarkiertem Knoten vj und
											   %	 f(eij) > 0 markiere vj mit (-v, δj), wobei δj die kleinere der beiden Zahlen
											   %	 f(eij) und δi ist

											   %io:nl(), io:fwrite("Vor dem markieren!"), io:nl(),
											   %erlang:display(Queue),
											   %timer:sleep(1000),

											   io:nl(), io:fwrite("Queue: "), erlang:display(Queue), io:nl(),

											   %AlleMarkedVertices = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), marked, Graph) =/= {"nil", "nil"}) and (graph_adt:getValV(lists:nth(2, X), inspected, Graph) == "false")],
											   %OldestMarkedVertex = lists:nth(1, AlleMarkedVertices),
											   OldestElementAndRestOfQueue = queue:out(Queue),
											   {{_, VertexExtracted}, RestQueue} = OldestElementAndRestOfQueue,
											   Vertex = lists:nth(1, VertexExtracted),

											   io:nl(), io:fwrite("Vertex: "), erlang:display(Vertex), io:nl(),
											   io:nl(), io:fwrite("RestQueue: "), erlang:display(RestQueue), io:nl(),

											   NewForwardMarkedGraphWithQueue = forwardEdges(Vertex, RestQueue, graph_adt:setValV(lists:nth(2, Vertex), inspected, "true", Graph)),

											   io:nl(), io:fwrite("NewForwardMarkedGraphWithQueue: "), erlang:display(element(1, NewForwardMarkedGraphWithQueue)), io:nl(),

											   NewBackwardMarkedGrapWithQueue = backwardEdges(Vertex, element(2, NewForwardMarkedGraphWithQueue), graph_adt:setValV(lists:nth(2, Vertex), inspected, "true", element(1, NewForwardMarkedGraphWithQueue))),
											   NewMarkedGraph = element(1, NewBackwardMarkedGrapWithQueue),

											   %io:nl(), io:fwrite("Nach dem markieren!"), io:nl(),
											   %erlang:display(Queue),
											   %timer:sleep(1000),

											   % Schritt 2C - Falls die Senke markiert ist, gehe zu Schritt 3, sonst zu 2A
											   Target = [X || X <- element(1, NewMarkedGraph), graph_adt:getValV(lists:nth(2, X), name, NewMarkedGraph) == "s"],
											   TargetMarked = graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, NewMarkedGraph),

											   if
													TargetMarked =/= {"nil", "nil"} -> step3(NewMarkedGraph); % gehe zu Schritt 3
						  											 		   true -> step2(NewMarkedGraph, element(2, NewBackwardMarkedGrapWithQueue))  % gehe zu Schritt 2A
											   end
	end.

% Schritt 3 - Vergößerung der Flußstärke
step3(Graph) ->
	% Bei s beginnend lässt sich anhand der Markierungen der gefundene vergrößernde Weg bis
	% zum Knoten q rückwärts durchlaufen. Für jede Vorwärtskante wird f(eij) um δs erhöht und
	% für jede Rückwärtskante wird f(eij) um δs vermindert. Anschließend werden bei allen
	% Knoten mit Ausnahme von q die Markierungen entfernt. Danach wieder zu Schritt 2A
	
	io:fwrite("------- SCHRITT 3 ---------"),
	Target = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "s"],
	FoundPath = findPath([Target], Graph),
	ReversedPath = lists:reverse(FoundPath),
	NewFlow = setFlow(ReversedPath, Graph),
	Queue = queue:new(),
	Source = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	step2(resetMarksAndInspected(element(1, NewFlow), NewFlow), queue:in(Source, Queue)).

% Schritt 4 - Es gibt keinen vergrößernden Weg
step4(Graph) ->
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
	io:fwrite("MaximumFlow: "), io:write(MaximumFlow), io:nl(), io:nl(),
	Graph.
%%================================================================================================================
%% 												HILFSMETHODEN	
%%================================================================================================================

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

% Gibt ein Boolean zurück, ob alle markierten Knoten auch inspiziert wurden
areAllMarkedVerticesInspected(Graph, [], BoolList) ->
	% Rückgabewert true, wenn alle markierten Knoten auch inspiziert, sonst false
	FalseIncluded = lists:member(false, BoolList),

	if
		(not FalseIncluded) == true -> true;
				     		   true -> false
	end;
areAllMarkedVerticesInspected(Graph, [H|T], BoolList) ->
	% Markierte Knoten ausfindig machen
	MarkedValue = graph_adt:getValV(lists:nth(2, H), marked, Graph),

	if
		% Falls Knoten markiert, prüfe ob auch inspiziert
		MarkedValue =/= {"nil", "nil"} -> areAllMarkedVerticesInspected(Graph, T, BoolList ++ [checkIfInspected(Graph, H)]);

								  % Falls nicht, prüfe nächsten Knoten
					   			  true -> areAllMarkedVerticesInspected(Graph, T, BoolList)
	end.

% Prüft ob ein Vertex inspiziert wurde
checkIfInspected(Graph, Vertex) ->
	Inspected = graph_adt:getValV(lists:nth(2, Vertex), inspected, Graph),

	if
		Inspected == "true" -> true;
					   true -> false
	end.

% Führt den Schritt der Markierung für die Vorwärtskanten durch
%	•(Vorwärtskante) Für jede Kante eij € O(vi) mit unmarkierterm Knoten vj und 
% 	 f(eij) < c(eij) markiere vj mit (+vi, δj), wobei δj die kleinere der beiden Zahlen
%	 c(eij) - f(eij) und δi ist
forwardEdges(OldestMarkedVertex, Queue, Graph) ->
	ID = lists:nth(2, OldestMarkedVertex),
	%io:fwrite("Vertex"), erlang:display(OldestMarkedVertex), io:nl(), 
	%io:fwrite("Queue"), erlang:display(Queue), io:nl(),
	%{Vertex, EdgesD, EdgesU} = Graph,
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	ForwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == t) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	ForwardVertices = [X || X <- element(1, Graph), Y <- ForwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	%ForwardVerticesWithFreeSpace = [X || X <- ForwardVertices, list_to_integer(element(1, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph))) > list_to_integer(element(2, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph)))],
	markForwardVertices(OldestMarkedVertex, ForwardVertices, Queue, Graph).

% Führt den Schritt der Markierung für die Rückwärtskanten durch
%	•(Rückwärtskante) Für jede Kante eij € I(vi) mit unmarkiertem Knoten vj und
%	 f(eij) > 0 markiere vj mit (-v, δj), wobei δj die kleinere der beiden Zahlen
%	 f(eij) und δi ist
backwardEdges(OldestMarkedVertex, Queue, Graph) ->
	ID = lists:nth(2, OldestMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	BackwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == s) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	BackwardVertices = [X || X <- element(1, Graph), Y <- BackwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	%io:fwrite("BackwardVertices: "), erlang:display(BackwardVertices),
	%BackwardVerticesWithFreeSpace = [X || X <- BackwardVertices, (list_to_integer(element(2, graph_adt:getValE({ID, lists:nth(2, X)}, maxis, Graph)) > 0))],
	markBackwardVertices(OldestMarkedVertex, BackwardVertices, Queue, Graph).

% Markiert die Vertices für die die Bedingungen zu treffen aus forwardEdges
markForwardVertices(OldestMarkedVertex, [], Queue, Graph) ->
	{Graph, Queue};
markForwardVertices(OldestMarkedVertex, [H|T], Queue, Graph) ->
	Maxis = graph_adt:getValE({lists:nth(2, OldestMarkedVertex), lists:nth(2, H)}, maxis, Graph),
	Capacity = element(1, Maxis),
	Flow = element(2, Maxis),

	if
		Capacity > Flow -> NewGraph = graph_adt:setValV(lists:nth(2, H), marked, {"+" ++ graph_adt:getValV(lists:nth(2, OldestMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(1, graph_adt:getValE({lists:nth(2, OldestMarkedVertex), lists:nth(2, H)}, maxis, Graph))) - list_to_integer(element(2, graph_adt:getValE({lists:nth(2, OldestMarkedVertex), lists:nth(2, H)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, OldestMarkedVertex), marked, Graph)))))}, Graph),
						   Vertex = [X || X <- element(1, NewGraph), lists:nth(2, X) == lists:nth(2, H)],
						   io:nl(), io:fwrite("NEUER VERTEX: "), erlang:display(Vertex), io:nl(),
						   markForwardVertices(OldestMarkedVertex, T, queue:in([H], Queue), NewGraph);
				   true -> markForwardVertices(OldestMarkedVertex, T, Queue, Graph)
	end.

% Markiert die Vertices für die die Bedingungen zu treffen aus backwardEdges
markBackwardVertices(OldestMarkedVertex, [], Queue, Graph) ->
	{Graph, Queue};
markBackwardVertices(OldestMarkedVertex, [H|T], Queue, Graph) ->
	Maxis = graph_adt:getValE({lists:nth(2, H), lists:nth(2, OldestMarkedVertex)}, maxis, Graph),
	%io:fwrite("Maxis: "), erlang:display(Maxis), io:nl(),
	Flow = list_to_integer(element(2, Maxis)),

	if
		Flow > 0 -> NewGraph = graph_adt:setValV(lists:nth(2, H), marked, {"-" ++ graph_adt:getValV(lists:nth(2, OldestMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(2, graph_adt:getValE({lists:nth(2, H), lists:nth(2, OldestMarkedVertex)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, OldestMarkedVertex), marked, Graph)))))}, Graph),
					Vertex = [X || X <- element(1, NewGraph), lists:nth(2, X) == lists:nth(2, H)],
					io:nl(), io:fwrite("NEUER VERTEX RÜCKWÄRTS: "), erlang:display(Vertex), io:nl(),
					markBackwardVertices(OldestMarkedVertex, T, queue:in([H], Queue), NewGraph);
			true -> markBackwardVertices(OldestMarkedVertex, T, Queue, Graph)
	end.

% Sucht vom Target den Weg Rückwärts zurücl zum Source und gibt eine Liste zurück mit den Vertices
findPath(Result, Graph) ->
	Vertex = lists:nth(1, Result),
	Predecessor = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), name, Graph) == (lists:nthtail(1, element(1, graph_adt:getValV(lists:nth(2, lists:nth(1, Vertex)), marked, Graph)))))],
	if
		Predecessor == [] -> Result;
					 true -> findPath([Predecessor] ++ Result, Graph)
	end.

% Setzt für die Kanten den neuen tatsächlichen Fluss Rückwärts beginnend beim Target auf den Wert des Flusses vom Target (s)
% Für jede Vorwärtskante wird f(eij) um δs erhöht und
% für jede Rückwärtskante wird f(eij) um δs vermindert. 
setFlow([], Graph) ->
	Graph;
setFlow([H|T], Graph) ->
	Forward = 43, % Steht für + in Dezimal für ASCII
	Backward = 45, % Steht für - in Dezimal für ASCII
	Target = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "s"],
	TargetFlowAsInt = list_to_integer(element(2, graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, Graph))),
	AttrMarkedValue = graph_adt:getValV(lists:nth(2, lists:nth(1, H)), marked, Graph),
	Predecessor = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == lists:nthtail(1, element(1, AttrMarkedValue))],
	if
		Predecessor == [] -> setFlow(T, Graph);
					 true -> ForwardOrBackward = lists:nth(1, element(1, AttrMarkedValue)),
							 IDPredecessor = lists:nth(2, lists:nth(1, Predecessor)),
							 ID = lists:nth(2, lists:nth(1, H)),
							 if
		 						 ForwardOrBackward == Forward -> setFlow(T, graph_adt:setValE({IDPredecessor, ID}, maxis, {element(1, graph_adt:getValE({IDPredecessor, ID}, maxis, Graph)), integer_to_list((list_to_integer((element(2, graph_adt:getValE({IDPredecessor, ID}, maxis, Graph)))) + TargetFlowAsInt))}, Graph));
								ForwardOrBackward == Backward -> setFlow(T, graph_adt:setValE({ID, IDPredecessor}, maxis, {element(1, graph_adt:getValE({ID, IDPredecessor}, maxis, Graph)), integer_to_list(list_to_integer(element(2, graph_adt:getValE({ID, IDPredecessor}, maxis, Graph))) - TargetFlowAsInt)}, Graph));
														 true -> io:fwrite("WEDER + noch - !!!!!!!!")
							 end
	end.

% Entfertn alle Markierungen, bis auf die des Source Vertexes (q)
resetMarksAndInspected([], Graph) ->
	Graph;
resetMarksAndInspected([H|T], Graph) ->
	VertexName = graph_adt:getValV(lists:nth(2, H), name, Graph),
	if
		VertexName =/= "q" -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), marked, {"nil", "nil"}, (graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))));
					  true -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))
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