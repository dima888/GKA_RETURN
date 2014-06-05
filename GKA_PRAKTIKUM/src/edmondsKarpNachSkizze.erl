% cd("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//src").
% c(edmondsKarpNachSkizze).
% G = graph_parser:importGraph("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//Dokumentation//grbuch.txt", "maxis").
% G1 = edmondsKarpNachSkizze:edmondsKarp(G).

-module(edmondsKarpNachSkizze).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

edmondsKarp(Graph) ->
	% initialisierungPrivat durchführen und zu Schritt 2 gehen
	findFlowPath(element(1, initialisierung(Graph)), element(2, initialisierung(Graph))).

%% Initialisierung des Graphen
initialisierung(Graph) -> 
	SourceVertex = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	NewQueue = queue:new(),
	NewGraph = graph_adt:setValV(lists:nth(2, lists:nth(1, SourceVertex)), marked, {"undefined", "576460753303423488"}, initialisierungPrivat(Graph, [])),
	SourceVertexModified = [X || X <- element(1, NewGraph), graph_adt:getValV(lists:nth(2, X), name, NewGraph) == "q"],
	{NewGraph, queue:in(SourceVertexModified, NewQueue)}.

%% Wege bestimmen
findFlowPath(Graph, Queue) ->
	AllMarkedVerticesInspected = areAllMarkedVerticesInspected(Graph, element(1, Graph), []),
	
	if
		 AllMarkedVerticesInspected == true -> minCut(Graph);
			   						   true -> OldestElementAndRestOfQueue = queue:out(Queue),
											   {{_, VertexExtracted}, RestQueue} = OldestElementAndRestOfQueue,
											   Vertex = lists:nth(1, VertexExtracted),
											   NewForwardMarkedGraphWithQueue = forwardEdges(Vertex, RestQueue, graph_adt:setValV(lists:nth(2, Vertex), inspected, "true", Graph)),
											   NewBackwardMarkedGrapWithQueue = backwardEdges(Vertex, element(2, NewForwardMarkedGraphWithQueue), graph_adt:setValV(lists:nth(2, Vertex), inspected, "true", element(1, NewForwardMarkedGraphWithQueue))),
											   NewMarkedGraph = element(1, NewBackwardMarkedGrapWithQueue),
											   Target = [X || X <- element(1, NewMarkedGraph), graph_adt:getValV(lists:nth(2, X), name, NewMarkedGraph) == "s"],
											   TargetMarked = graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, NewMarkedGraph),

											   if
													TargetMarked =/= {"nil", "nil"} -> raiseFlow(NewMarkedGraph);
						  											 		   true -> findFlowPath(NewMarkedGraph, element(2, NewBackwardMarkedGrapWithQueue))
											   end
	end.

%% Raise-Flow Funktion
raiseFlow(Graph) ->	
	Target = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "s"],
	FoundPath = findPath([Target], Graph),
	ReversedPath = lists:reverse(FoundPath),
	NewFlow = setFlow(ReversedPath, Graph),
	Queue = queue:new(),
	Source = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	findFlowPath(resetMarksAndInspected(element(1, NewFlow), NewFlow), queue:in(Source, Queue)).

%% Min-Cut bestimmen
minCut(Graph) ->
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

initialisierungPrivat({Vertices, EdgesD, EdgesU}, Result) ->
	% initialisierungPrivat
	setAttributsV(setAttributsE({Vertices, EdgesD, EdgesU}, EdgesD), Vertices).

setAttributsV(Graph, []) ->
	Graph;
setAttributsV(Graph, [H|T]) ->
	ID = lists:nth(2, H),
	setAttributsV(graph_adt:setValV(ID, marked, {"nil", "nil"}, graph_adt:setValV(ID, inspected, "false", Graph)), T).

setAttributsE(Graph, []) ->
	Graph;
setAttributsE(Graph, [H|T]) ->
	ID = lists:nth(2, H),
	setAttributsE(graph_adt:setValE(ID, maxis, {element(1, graph_adt:getValE(ID, maxis, Graph)), "0"}, Graph), T).

areAllMarkedVerticesInspected(Graph, [], BoolList) ->
	FalseIncluded = lists:member(false, BoolList),

	if
		(not FalseIncluded) == true -> true;
				     		   true -> false
	end;
areAllMarkedVerticesInspected(Graph, [H|T], BoolList) ->
	MarkedValue = graph_adt:getValV(lists:nth(2, H), marked, Graph),

	if
		MarkedValue =/= {"nil", "nil"} -> areAllMarkedVerticesInspected(Graph, T, BoolList ++ [checkIfInspected(Graph, H)]);
					   			  true -> areAllMarkedVerticesInspected(Graph, T, BoolList)
	end.

checkIfInspected(Graph, Vertex) ->
	Inspected = graph_adt:getValV(lists:nth(2, Vertex), inspected, Graph),

	if
		Inspected == "true" -> true;
					   true -> false
	end.

forwardEdges(OldestMarkedVertex, Queue, Graph) ->
	ID = lists:nth(2, OldestMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	ForwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == t) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	ForwardVertices = [X || X <- element(1, Graph), Y <- ForwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	markForwardVertices(OldestMarkedVertex, ForwardVertices, Queue, Graph).

backwardEdges(OldestMarkedVertex, Queue, Graph) ->
	ID = lists:nth(2, OldestMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	BackwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == s) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	BackwardVertices = [X || X <- element(1, Graph), Y <- BackwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	markBackwardVertices(OldestMarkedVertex, BackwardVertices, Queue, Graph).

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

markBackwardVertices(OldestMarkedVertex, [], Queue, Graph) ->
	{Graph, Queue};
markBackwardVertices(OldestMarkedVertex, [H|T], Queue, Graph) ->
	Maxis = graph_adt:getValE({lists:nth(2, H), lists:nth(2, OldestMarkedVertex)}, maxis, Graph),
	Flow = list_to_integer(element(2, Maxis)),

	if
		Flow > 0 -> NewGraph = graph_adt:setValV(lists:nth(2, H), marked, {"-" ++ graph_adt:getValV(lists:nth(2, OldestMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(2, graph_adt:getValE({lists:nth(2, H), lists:nth(2, OldestMarkedVertex)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, OldestMarkedVertex), marked, Graph)))))}, Graph),
					Vertex = [X || X <- element(1, NewGraph), lists:nth(2, X) == lists:nth(2, H)],
					io:nl(), io:fwrite("NEUER VERTEX RÜCKWÄRTS: "), erlang:display(Vertex), io:nl(),
					markBackwardVertices(OldestMarkedVertex, T, queue:in([H], Queue), NewGraph);
			true -> markBackwardVertices(OldestMarkedVertex, T, Queue, Graph)
	end.

findPath(Result, Graph) ->
	Vertex = lists:nth(1, Result),
	Predecessor = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), name, Graph) == (lists:nthtail(1, element(1, graph_adt:getValV(lists:nth(2, lists:nth(1, Vertex)), marked, Graph)))))],
	if
		Predecessor == [] -> Result;
					 true -> findPath([Predecessor] ++ Result, Graph)
	end.

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

resetMarksAndInspected([], Graph) ->
	Graph;
resetMarksAndInspected([H|T], Graph) ->
	VertexName = graph_adt:getValV(lists:nth(2, H), name, Graph),
	if
		VertexName =/= "q" -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), marked, {"nil", "nil"}, (graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))));
					  true -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))
	end.

print({Vertices, EdgesD, EdgesU}) ->
	io:nl(), io:fwrite("------------- Vertices -------------"), io:nl(),
	printAll(Vertices),

	io:fwrite("------------- EdgesD -------------"), io:nl(),
	printAll(EdgesD).

printAll([]) ->
	io:nl();
printAll([H|T]) ->
	erlang:display(H), io:nl(),
	printAll(T).