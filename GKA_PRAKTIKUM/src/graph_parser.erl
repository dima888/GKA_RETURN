%% @author foxhound
%% @doc @todo Add description to graph_parser.


-module(graph_parser).

%% ====================================================================
%% API functions
%% ====================================================================
-export([importGraph/2, readlines/1, costImport/1, costDirektedImport/6, constUndirektedImport/6,
		  countLines/1, maxisImport/1, maxisDirektedImport/6, maxisUndirektedImport/6]).

%% ====================================================================
%% Internal functions
%% ====================================================================
%TODO: FilePath verlagern || FilePath = Datei
importGraph(Datei, Attr) -> 
	if Attr == "cost" -> 
		   costImport(Datei);
	   Attr == "maxis" -> 
		   maxisImport(Datei);
	   true -> notAllowedAttribut
	end.


%---------- SUPERMETHODE, entscheiden ueber gerichteten oder ungerichteten Graphen ------------
maxisImport(Datei) -> 
	%Datei = "C:\\Users\\foxhound\\Desktop\\test.txt",
	{ok, Device} = file:open(Datei, [read]),
	
	%Erste Zeile, wo angegeben wird ob es gerichtet oder ungerichtet ist
	Row = io:get_line(Device, []),
	
	%IDs werden immer plus 2 genommen, somit vermeiden wir gleiche Ids
	if Row == "#gerichtet\n" -> maxisDirektedImport(Datei, graph_adt:new_AlGraph(), 1, 2, Device, 1);
	   Row == "#ungerichtet\n" -> maxisUndirektedImport(Datei, graph_adt:new_AlGraph(), 1, 2, Device, 1);
	   true -> format_unknow
	end.
	 
%---------- SUPERMETHODE, entscheiden ueber gerichteten oder ungerichteten Graphen ------------
costImport(Datei) -> 
	%Datei = "C:\\Users\\foxhound\\Desktop\\test.txt",
	{ok, Device} = file:open(Datei, [read]),
	
	%Erste Zeile, wo angegeben wird ob es gerichtet oder ungerichtet ist
	Row = io:get_line(Device, []),
	
	%IDs werden immer plus 2 genommen, somit vermeiden wir gleiche Ids
	if Row == "#gerichtet\n" -> costDirektedImport(Datei, graph_adt:new_AlGraph(), 1, 2, Device, 1);
	   Row == "#ungerichtet\n" -> constUndirektedImport(Datei, graph_adt:new_AlGraph(), 1, 2, Device, 1);
	   true -> format_unknow
	end.

%--------------- ALGORITHMUS ZUM IMPORTIEREN EINES GERICHTETEN GRAPHEN MAXIS ------------------
maxisDirektedImport(Datei, Graph, V_ID1, V_ID2, Device, Count) ->
	%---------- ABBRUCHBEDINGUNG -----------------
	LinesNumber = graph_parser:countLines(Datei),
	if ( Count == LinesNumber) -> 
		   Graph; 
	   true -> 
	
	%FilePath = "C:\\Users\\foxhound\\Desktop\\test.txt",
	%FilePath = "C:\\Users\\foxhound\\Desktop\\Beispiel.txt",
	%"C:\\Users\\foxhound\\Desktop\\beispiel.txt"
	Row = io:get_line(Device, []),
	
	PartGraph = string:tokens(Row, ", \n "),
	
	%Alle AttributeValue aus der Textdatei raus hollen
	SourceValName = lists:nth(1, PartGraph),
	TargetValName = lists:nth(2, PartGraph),
	CoustVal = lists:nth(3, PartGraph),
	MaxisVal = lists:nth(4, PartGraph),
	
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
			ModifyGraph_3 = graph_adt:setValE({ExistingID_1, ExistingID_2}, maxis, MaxisVal, ModifyGraph_2),
			
			%Zurueck in die Rekursion
			maxisDirektedImport(Datei, ModifyGraph_3, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_5 = graph_adt:setValE({ExistingID, V_ID2}, maxis, MaxisVal, ModifyGraph_4),
			
			%Zurueck in die Rekursion
			maxisDirektedImport(Datei, ModifyGraph_5, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
	   
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
		    ModifyGraph_5 = graph_adt:setValE({V_ID1, ExistingID}, maxis, MaxisVal, ModifyGraph_4),
		   
		   %Zurueck in die Rekursion
		   maxisDirektedImport(Datei, ModifyGraph_5, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_7 = graph_adt:setValE({V_ID1, V_ID2}, maxis, MaxisVal, ModifyGraph_6),
	
			%Zurueck in die Rekursion
			maxisDirektedImport(Datei, ModifyGraph_7, V_ID1 + 2, V_ID2 + 2, Device, Count + 1)
		    end
	end.

%--------------- ALGORITHMUS ZUM IMPORTIEREN EINES UNGERICHTETEN GRAPHEN MAXIS ------------------
maxisUndirektedImport(Datei, Graph, V_ID1, V_ID2, Device, Count) -> 
%---------- ABBRUCHBEDINGUNG -----------------
	LinesNumber = graph_parser:countLines(Datei),
	if ( Count == LinesNumber) -> 
		   Graph; 
	   true -> 
	
	%FilePath = "C:\\Users\\foxhound\\Desktop\\test.txt",
	%FilePath = "C:\\Users\\foxhound\\Desktop\\Beispiel.txt",
	%"C:\\Users\\foxhound\\Desktop\\beispiel.txt"
	Row = io:get_line(Device, []),
	
	PartGraph = string:tokens(Row, ", \n "),
	
	%Alle AttributeValue aus der Textdatei raus hollen
	SourceValName = lists:nth(1, PartGraph),
	TargetValName = lists:nth(2, PartGraph),
	CoustVal = lists:nth(3, PartGraph),
	MaxisVal = lists:nth(4, PartGraph),

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
			ModifyGraph = graph_adt:addEdgeU(ExistingID_1, ExistingID_2, Graph),
			
			%Attribut an die Kante kleben
			ModifyGraph_2 = graph_adt:setValE({ExistingID_1, ExistingID_2}, cost, CoustVal, ModifyGraph),
			ModifyGraph_3 = graph_adt:setValE({ExistingID_1, ExistingID_2}, maxis, MaxisVal, ModifyGraph_2),
			
			%Zurueck in die Rekursion
			maxisUndirektedImport(Datei, ModifyGraph_3, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_3 = graph_adt:addEdgeU(ExistingID, V_ID2, ModifyGraph_2),
			
			%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({ExistingID, V_ID2}, cost, CoustVal, ModifyGraph_3),
			ModifyGraph_5 = graph_adt:setValE({ExistingID, V_ID2}, maxis, MaxisVal, ModifyGraph_4),
			
			%Zurueck in die Rekursion
			maxisUndirektedImport(Datei, ModifyGraph_5, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
	   
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
			ModifyGraph_3 = graph_adt:addEdgeU(V_ID1, ExistingID, ModifyGraph_2),
		   
		   	%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({V_ID1, ExistingID}, cost, CoustVal, ModifyGraph_3),
		    ModifyGraph_5 = graph_adt:setValE({V_ID1, ExistingID}, maxis, MaxisVal, ModifyGraph_4),
		   
		   %Zurueck in die Rekursion
		   maxisUndirektedImport(Datei, ModifyGraph_5, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_5 = graph_adt:addEdgeU(V_ID1, V_ID2, ModifyGraph_4),
			
			%Attribut an die Kante kleben
			ModifyGraph_6 = graph_adt:setValE({V_ID1, V_ID2}, cost, CoustVal, ModifyGraph_5),
			ModifyGraph_7 = graph_adt:setValE({V_ID1, V_ID2}, maxis, MaxisVal, ModifyGraph_6),
	
			%Zurueck in die Rekursion
			maxisUndirektedImport(Datei, ModifyGraph_7, V_ID1 + 2, V_ID2 + 2, Device, Count + 1)
		    end
	end.


%--------------- ALGORITHMUS ZUM IMPORTIEREN EINES GERICHTETEN GRAPHEN COST ------------------
costDirektedImport(Datei, Graph, V_ID1, V_ID2, Device, Count) ->
	
	%---------- ABBRUCHBEDINGUNG -----------------
	LinesNumber = graph_parser:countLines(Datei),
	if ( Count == LinesNumber) -> 
		   Graph; 
	   true -> 
	
	
	%FilePath = "C:\\Users\\foxhound\\Desktop\\test.txt",
	%FilePath = "C:\\Users\\foxhound\\Desktop\\Beispiel.txt",
	%"C:\\Users\\foxhound\\Desktop\\beispiel.txt"
	Row = io:get_line(Device, []),
	
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
			costDirektedImport(Datei, ModifyGraph_2, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			costDirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
	   
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
		   costDirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			costDirektedImport(Datei, ModifyGraph_6, V_ID1 + 2, V_ID2 + 2, Device, Count + 1)
		    end
	
	end.
	
%--------------- ALGORITHMUS ZUM IMPORTIEREN EINES UNGERICHTETEN GRAPHEN COST ------------------
constUndirektedImport(Datei, Graph, V_ID1, V_ID2, Device, Count) -> 
		%---------- ABBRUCHBEDINGUNG -----------------
	LinesNumber = graph_parser:countLines(Datei),
	if ( Count == LinesNumber) -> 
		   Graph; 
	   true -> 
	
	%graph_parser:costImport("C:\\Users\\foxhound\\Desktop\\ungerichtet.txt").
	Row = io:get_line(Device, []),
	
	PartGraph = string:tokens(Row, ", \n "),
	
	%Alle AttributeValue aus der Textdatei raus hollen, Hier spielt Source und Target keine Rolle
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
			ModifyGraph = graph_adt:addEdgeU(ExistingID_1, ExistingID_2, Graph),
			
			%Attribut an die Kante kleben
			ModifyGraph_2 = graph_adt:setValE({ExistingID_1, ExistingID_2}, cost, CoustVal, ModifyGraph),
			
			%Zurueck in die Rekursion
			constUndirektedImport(Datei, ModifyGraph_2, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_3 = graph_adt:addEdgeU(ExistingID, V_ID2, ModifyGraph_2),
			
			%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({ExistingID, V_ID2}, cost, CoustVal, ModifyGraph_3),
			
			%Zurueck in die Rekursion
			constUndirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
	   
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
			ModifyGraph_3 = graph_adt:addEdgeU(V_ID1, ExistingID, ModifyGraph_2),
		   
		   	%Attribut an die Kante kleben
			ModifyGraph_4 = graph_adt:setValE({V_ID1, ExistingID}, cost, CoustVal, ModifyGraph_3),
		   
		   %Zurueck in die Rekursion
		   constUndirektedImport(Datei, ModifyGraph_4, V_ID1 + 2, V_ID2 + 2, Device, Count + 1);
		   
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
			ModifyGraph_5 = graph_adt:addEdgeU(V_ID1, V_ID2, ModifyGraph_4),
			
			%Attribut an die Kante kleben
			ModifyGraph_6 = graph_adt:setValE({V_ID1, V_ID2}, cost, CoustVal, ModifyGraph_5),
	
			%Zurueck in die Rekursion
			constUndirektedImport(Datei, ModifyGraph_6, V_ID1 + 2, V_ID2 + 2, Device, Count + 1)
		    end
	
	end.

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

countLines(File) ->
	Line = readlines(File),
%"#gerichtet\ns,u,10\ns,x,5\nu,v,1\nu,x,2\nx,u,3\nx,y,2\ny,s,7\ny,v,6\nv,y,4"
%"C:\\Users\\foxhound\\Desktop\\test.txt"
	Z = [ [X] || X <- Line],
	Res = [ X || X <- Z, X == "\n"],
	L = length(Res) + 1 .
