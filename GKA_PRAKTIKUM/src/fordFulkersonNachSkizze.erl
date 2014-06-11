% cd("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//src").
% c(fordFulkersonNachSkizze).
% G = graph_parser:importGraph("//Users//Flah//Dropbox//WorkSpace//GKA_RETURN//GKA_PRAKTIKUM//Dokumentation//graph9.txt", "maxis").
% G1 = fordFulkersonNachSkizze:fordFulkerson(G, "Quelle", "Senke").

-module(fordFulkersonNachSkizze).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

fordFulkerson(Graph, SourceName, TargetName) ->
	SourceID = [lists:nth(2, X) || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == SourceName],
	TargetID = [lists:nth(2, X) || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == TargetName],

	Graph1 = graph_adt:setValV(lists:nth(1, SourceID), name, "q", Graph),
	Graph2 = graph_adt:setValV(lists:nth(1, TargetID), name, "s", Graph1),

	InitGraphAndCount = initialisierung(Graph2, 0),
	findFlowPath(element(1, InitGraphAndCount), element(2, InitGraphAndCount)).

%% Initialisierung des Graphen
initialisierung(Graph, Counter) -> 
	SourceVertex = [X || X <- element(1, Graph), graph_adt:getValV(lists:nth(2, X), name, Graph) == "q"],
	%io:fwrite("SOURCE GEFUDNEN: "), io:write(SourceVertex), io:nl(),
	{graph_adt:setValV(lists:nth(2, lists:nth(1, SourceVertex)), marked, {"undefined", "576460753303423488"}, initialisierungPrivat(Graph, [])), Counter + 2}.

%% Wege bestimmen
findFlowPath(Graph, Counter) ->
	AllMarkedVerticesInspectedAndCounter = areAllMarkedVerticesInspected(Graph, element(1, Graph), [], Counter),
	AllMarkedVerticesInspected = element(1, AllMarkedVerticesInspectedAndCounter),
	NewCounter = element(2, AllMarkedVerticesInspectedAndCounter),
	
	if
		 AllMarkedVerticesInspected == true -> minCut(Graph, Counter);
			   						   true -> AlleMarkedVertices = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), marked, Graph) =/= {"nil", "nil"}) and (graph_adt:getValV(lists:nth(2, X), inspected, Graph) == "false")],
											   ArbitraryMarkedVertex = lists:nth(1, AlleMarkedVertices),
											   NewMarkedGraphAndCounter = forwardEdges(ArbitraryMarkedVertex, graph_adt:setValV(lists:nth(2, ArbitraryMarkedVertex), inspected, "true", Graph), NewCounter),
											   NewMarkedGraph = element(1, NewMarkedGraphAndCounter),
											   NewCounter1 = element(2, NewMarkedGraphAndCounter),
											   NewMarkedGraph1AndCounter = backwardEdges(ArbitraryMarkedVertex, graph_adt:setValV(lists:nth(2, ArbitraryMarkedVertex), inspected, "true", NewMarkedGraph), NewCounter1),
											   NewMarkedGraph1 = element(1, NewMarkedGraph1AndCounter),
											   NewCounter2 = element(2, NewMarkedGraph1AndCounter),

											   %io:nl(), io:fwrite("Alle Markierten Knoten:"), erlang:display(AlleMarkedVertices), io:nl(),
											   %erlang:display(NewMarkedGraph1),

											   Target = [X || X <- element(1, NewMarkedGraph1), graph_adt:getValV(lists:nth(2, X), name, NewMarkedGraph1) == "s"],
											   TargetMarked = graph_adt:getValV(lists:nth(2, lists:nth(1, Target)), marked, NewMarkedGraph1),

											   if
													TargetMarked =/= {"nil", "nil"} -> raiseFlow(NewMarkedGraph1, NewCounter2 + length(element(1, NewMarkedGraph1)) + 1);
						  											 		   true -> findFlowPath(NewMarkedGraph1, NewCounter2 + length(element(1, NewMarkedGraph1)) + 1)
											   end
	end.

%% Raise-Flow Funktion
raiseFlow(Graph, Counter) ->
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

%% Min-Cut bestimmen
minCut(Graph, Counter) ->
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

initialisierungPrivat({Vertices, EdgesD, EdgesU}, Result) ->
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

areAllMarkedVerticesInspected(Graph, [], BoolList, Counter) ->
	FalseIncluded = lists:member(false, BoolList),

	if
		(not FalseIncluded) == true -> {true, Counter};
				     		   true -> {false, Counter}
	end;
areAllMarkedVerticesInspected(Graph, [H|T], BoolList, Counter) ->
	MarkedValue = graph_adt:getValV(lists:nth(2, H), marked, Graph),

	if
		MarkedValue =/= {"nil", "nil"} -> CheckWithCount = checkIfInspected(Graph, H, Counter),
										  Check = [element(1, CheckWithCount)],
										  NewCounter = element(2, CheckWithCount),
										  areAllMarkedVerticesInspected(Graph, T, BoolList ++ Check, NewCounter + 1);
					   			  true -> areAllMarkedVerticesInspected(Graph, T, BoolList, Counter + 1)
	end.

checkIfInspected(Graph, Vertex, Counter) ->
	Inspected = graph_adt:getValV(lists:nth(2, Vertex), inspected, Graph),

	if
		Inspected == "true" -> {true, Counter + 1};
					   true -> {false, Counter + 1}
	end.

forwardEdges(ArbitraryMarkedVertex, Graph, Counter) ->
	ID = lists:nth(2, ArbitraryMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	ForwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == t) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	ForwardVertices = [X || X <- element(1, Graph), Y <- ForwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	Result = markForwardVertices(ArbitraryMarkedVertex, ForwardVertices, Graph, Counter  + length(AdjacentVertices)),
	{element(1, Result), element(2, Result)}.

backwardEdges(ArbitraryMarkedVertex, Graph, Counter) ->
	ID = lists:nth(2, ArbitraryMarkedVertex),
	AdjacentVertices = graph_adt:getAdjacent(ID, Graph),
	BackwardVerticesIDsThatAreNotMarked = [element(2, X) || X <- AdjacentVertices, ((element(1, X) == s) and (graph_adt:getValV(element(2, X), marked, Graph) == {"nil", "nil"}))],
	BackwardVertices = [X || X <- element(1, Graph), Y <- BackwardVerticesIDsThatAreNotMarked, lists:nth(2, X) == Y],
	Result = markBackwardVertices(ArbitraryMarkedVertex, BackwardVertices, Graph, Counter + length(AdjacentVertices)),
	{element(1, Result), element(2, Result)}.

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

markBackwardVertices(ArbitraryMarkedVertex, [], Graph, Counter) ->
	{Graph, Counter};
markBackwardVertices(ArbitraryMarkedVertex, [H|T], Graph, Counter) ->
	Maxis = graph_adt:getValE({lists:nth(2, H), lists:nth(2, ArbitraryMarkedVertex)}, maxis, Graph),
	Flow = list_to_integer(element(2, Maxis)),

	if
		Flow > 0 -> markBackwardVertices(ArbitraryMarkedVertex, T, graph_adt:setValV(lists:nth(2, H), marked, {"-" ++ graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), name, Graph), integer_to_list(min(list_to_integer(element(2, graph_adt:getValE({lists:nth(2, H), lists:nth(2, ArbitraryMarkedVertex)}, maxis, Graph))), list_to_integer(element(2, graph_adt:getValV(lists:nth(2, ArbitraryMarkedVertex), marked, Graph)))))}, Graph), Counter + 5);
			true -> markBackwardVertices(ArbitraryMarkedVertex, T, Graph, Counter)
	end.

findPath(Result, Graph, Counter) ->
	Vertex = lists:nth(1, Result),
	Predecessor = [X || X <- element(1, Graph), (graph_adt:getValV(lists:nth(2, X), name, Graph) == (lists:nthtail(1, element(1, graph_adt:getValV(lists:nth(2, lists:nth(1, Vertex)), marked, Graph)))))],
	if
		Predecessor == [] -> {Result, Counter + 2};
					 true -> findPath([Predecessor] ++ Result, Graph, Counter + 2)
	end.
 
raiseFlowPrivat([], Graph, Counter) ->
	{Graph, Counter};
raiseFlowPrivat([H|T], Graph, Counter) ->
	Forward = 43,
	Backward = 45,
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

resetMarksAndInspected([], Graph, Counter) ->
	{Graph, Counter};
resetMarksAndInspected([H|T], Graph, Counter) ->
	VertexName = graph_adt:getValV(lists:nth(2, H), name, Graph),
	if
		VertexName =/= "q" -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), marked, {"nil", "nil"}, (graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph))), Counter + 3);
					  true -> resetMarksAndInspected(T, graph_adt:setValV(lists:nth(2, H), inspected, "false", Graph), Counter + 2)
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