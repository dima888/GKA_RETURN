%% @author foxhound
%% @doc @todo Add description to graph_parser.


-module(graph_parser).

%% ====================================================================
%% API functions
%% ====================================================================
-export([importGraph/2, readlines/1, costImport/1, costDirektedImport/5]).



%% ====================================================================
%% Internal functions
%% ====================================================================
%TODO: FilePath verlagern || FilePath = Datei
importGraph(Datei, Attr) when Attr == "cost" ->	
	costImport(Datei).
	 
%---------- HILFS FUNKTION ------------
costImport(Datei) -> 
	%Datei = "C:\\Users\\foxhound\\Desktop\\test.txt",
	{ok, Device} = file:open(Datei, [read]),
	
	%Erste Zeile, wo angegeben wird ob es gerichtet oder ungerichtet ist
	Row = io:get_line(Device, []),
	
	%IDs werden immer plus 2 genommen, somit vermeiden wir gleiche Ids
	if Row == "#gerichtet\n" -> costDirektedImport(Datei, graph_adt:new_AlGraph(), 1, 2, Device);
	   true -> constUndirektedImport(Datei)
	end.

%---------- HILFS FUNKTION ------------
%TODO: Richtige Abbruch bedingung implementieren
costDirektedImport(Datei, Graph, V_ID1, V_ID2, Device) when V_ID1 == 15 -> Graph;
costDirektedImport(Datei, Graph, V_ID1, V_ID2, Device) ->
	%FilePath = "C:\\Users\\foxhound\\Desktop\\test.txt",
	%FilePath = "C:\\Users\\foxhound\\Desktop\\Beispiel3.txt",
	Row = io:get_line(Device, []),
%% 	io:write(Row),
	
	PartGraph = string:tokens(Row, ", \n "),
	
	%Alle AttributeValue aus der Textdatei raus hollen
	SourceValName = lists:nth(1, PartGraph),
	TargetValName = lists:nth(2, PartGraph),
	CoustVal = lists:nth(3, PartGraph),

	%Hier kommen die Pruefungen ob die IDs in den Graphen rein duerfen TODO: Keine Ahnung ob ich das noch brauche
	BoolValVertexFirst = graph_adt:includeValue(SourceValName, Graph),
	BoolValVertexSecond = graph_adt:includeValue(TargetValName, Graph),
	
	if ( (BoolValVertexFirst  == true) and (BoolValVertexSecond == true)  ) -> 
		   %TODO: Lesen und beraten, gegebenfalls in der Vorlesung ansprechen ob wir diesen Fall wirklich benoetigen
		   %in diesen Fall packt er ein und die gleiche Kante doppeln rein. Deshalb behandele ich diesen Fall erstmal nicht!
	
		   %Die schon vorhandene ID ausgraben
			Buffer = graph_adt:getIDFromAttrValue(SourceValName, Graph),
			ExistingID_1 = lists:nth(1, Buffer),
		   
			%Die schon vorhandene ID ausgraben
			Buffer_2 = graph_adt:getIDFromAttrValue(TargetValName, Graph),
			ExistingID_2 = lists:nth(1, Buffer_2),
			
			%Kante hinzu fuegen
			ModifyGraph = graph_adt:addEdgeD(ExistingID_1, ExistingID_2, Graph),
			
			%Attribut an die Kante kleben
			ModifyGraph_2 = graph_adt:setValE({ExistingID_1, ExistingID_2}, cost, CoustVal, ModifyGraph),
			
			%Zurueck in die Rekursion
			costDirektedImport(Datei, ModifyGraph_2, V_ID1 + 2, V_ID2 + 2, Device);
		   
	   %In diesen Fall ist die V_ID1 schon vorhanden und V_ID2 noch nicht
	   ( (BoolValVertexFirst  == true) and (BoolValVertexSecond == false)  ) -> 
		   	%Vertex an zweiter Stelle in .graph hinzu fuegen
			ModifyGraph = graph_adt:addVertex(V_ID2, Graph),
			
			%Dem Vertex das Attribut hinzu kleben
			ModifyGraph_2 = graph_adt:setValV(V_ID2, name, TargetValName, ModifyGraph),
	
			%Die schon vorhandene ID ausgraben
			Buffer = graph_adt:getIDFromAttrValue(SourceValName, ModifyGraph_2),
			ExistingID = lists:nth(1, Buffer),
			
			%Kante hinzu fuegen
			ModifyGraph_3 = graph_adt:addEdgeD(ExistingID, V_ID2, ModifyGraph_2),
			
			%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({ExistingID, V_ID2}, cost, CoustVal, ModifyGraph_3),
			
			%Zurueck in die Rekursion
			costDirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device);
	   
	   %In diesen Fall ist die V_ID2 schon vorhanden und V_ID1 noch nicht
	   ( (BoolValVertexFirst  == false) and (BoolValVertexSecond == true)  ) ->
		   %Vertex an erster Stelle in .graph hinzu fuegen
		   ModifyGraph = graph_adt:addVertex(V_ID1, Graph),
		   
		   	%Dem Vertex das Attribut hinzu kleben
			ModifyGraph_2 = graph_adt:setValV(V_ID1, name, TargetValName, ModifyGraph),
		   
		   	%Die schon vorhandene ID ausgraben
			Buffer = graph_adt:getIDFromAttrValue(SourceValName, ModifyGraph_2),
			ExistingID = lists:nth(1, Buffer),
		   
		   %Kante hinzu fuegen
			ModifyGraph_3 = graph_adt:addEdgeD(V_ID1, ExistingID, ModifyGraph_2),
		   
		   	%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({V_ID1, ExistingID}, cost, CoustVal, ModifyGraph_3),
		   
		   %Zurueck in die Rekursion
		   costDirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device);
		   
	   %%Das ist immer der Fall, wenn beide Vertices IDs im Graphen noch nicht vorhanden sind
	   true -> 		   		   
		   	%Verteces hinzu gefuegt
			ModifyGraph = graph_adt:addVertex(V_ID1, Graph), 
			
			%Dem Vertex das Attribut hinzu kleben
			ModifyGraph_2 = graph_adt:setValV(V_ID1, name, SourceValName, ModifyGraph),

			%Zweiten Vertex hinzu fuegen
			ModifyGraph_3 = graph_adt:addVertex(V_ID2, ModifyGraph_2),
			
			%Dem Vertex das Attribut hinzu kleben
			ModifyGraph_4 = graph_adt:setValV(V_ID2, name, TargetValName, ModifyGraph_3),
	
			%Kante hinzu fuegen
			ModifyGraph_5 = graph_adt:addEdgeD(V_ID1, V_ID2, ModifyGraph_4),
			
			%Attribut an die Kante kleben
			ModifyGraph_6 = graph_adt:setValE({V_ID1, V_ID2}, cost, CoustVal, ModifyGraph_5),
	
			%Zurueck in die Rekursion
			costDirektedImport(Datei, ModifyGraph_6, V_ID1 + 2, V_ID2 + 2, Device)
		   end.
	
	
	
%---------- HILFS FUNKTION ------------
constUndirektedImport(Datei) -> 
	X = 25.

readlines(FileName) ->
    {ok, Device} = file:open(FileName, [read]),
    try get_all_lines(Device)
      after file:close(Device)
    end.

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof  -> [];
        Line -> Line ++ get_all_lines(Device)
    end.