%% @author foxhound

%% Der Algorithmus von Hierholzer ist ein Algorithmus aus dem Gebiet der Graphentheorie mit dem man in einem ungerichteten Graphen Eulerkreise bestimmt.
%% Er geht auf Ideen von Carl Hierholzer zurück.
%% 
%% Voraussetzung: Sei G=(V,E) ein zusammenhängender Graph, der nur Knoten mit geradem Grad aufweist.
%% 
%%     1. Wähle einen beliebigen Knoten v_0 des Graphen und konstruiere von v_0 ausgehend einen Unterkreis K in G, der keine Kante in G zweimal durchläuft.
%%     2. Wenn K ein Eulerkreis ist, breche ab. Andernfalls:
%%     3. Vernachlässige nun alle Kanten des Unterkreises K.
%%     4. Am ersten Eckpunkt von K, dessen Grad größer 0 ist, lässt man nun einen weiteren Unterkreis K' entstehen, der keine Kante in K durchläuft
%%		  und keine Kante in G zweimal enthält.
%%     5. Füge in K den zweiten Kreis K' ein, indem der Startpunkt von K' durch alle Punkte von K' in der richtigen Reihenfolge ersetzt wird.
%%     6. Nenne jetzt den so erhaltenen Kreis K und fahre bei Schritt 2 fort.
%% 
%% Die Komplexität des Algorithmus ist linear in der Anzahl der Kanten.

%%--------------- Quelle: http://de.wikipedia.org/wiki/Algorithmus_von_Hierholzer ------------------


%% Definition 5.1 (Eulertour und Eulerpfad)
%% * Eine geschlossene Kantenfolge, die jede Kante eines Graphen genau einmal
%% enthält, heißt eine Eulertour.

%% * Ein Graph, der eine Eulertour besitzt, heißt ein eulerscher Graph.

%% * Eine Kantenfolge, die jede Kante eines Graphen genau einmal enthält
%% 	 und nicht geschlossen ist, heißt ein Eulerpfad.
%%   Es gilt dann:

%% Satz 5.1
%% * Ein ungerichteter Graph besitzt genau dann eine Eulertour, wenn jede
%%   Ecke einen geraden Grad besitzt.

%% * Ein ungerichteter Graph besitzt genau dann einen Eulerpfad, wenn genau
%%   zwei Ecken einen ungeraden Grad besitzen. Diese beiden Ecken sind die
%%   erste und die letzte Ecke des Eulerpfads.
%%-------Quelle: GRBuch Seite 117------------

%% @doc @todo Add description to hierholzer.


-module(hierholzer).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\Graphen\\bellman.txt", "cost").
%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\Graphen\\hier.txt", "cost"). 

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\bellman.txt", "cost").

%Graph = graph_parser:importGraph("c:\\users\\foxhound\\desktop\\wiki.txt", "cost").
%M1 = hierholzer:createUnderCircleVerion_2(Graph, 1, [], [], 1).
%M2 = hierholzer:createUnderCircleVerion_2(lists:nth(1, M1), 1, [], lists:nth(2, M1), 1).
%M3 = hierholzer:createUnderCircleVerion_2(lists:nth(1, M2), 6, [], lists:nth(2, M2), 6).

%Methode prueft, ob alle Knoten einen geraden Grad aufweisen: PRECONDITION
checkDirectOrder(Graph) -> 
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Ueber alle ID Iterieren, deren Inzidenten heraus hollen und auf gerade oder ungerade pruefen
	
	%Alle ID's heraus hollen
	Vertices_List = [ lists:nth(2, X) || X <- Vertices ],	
	
	checkDirectOder(Graph, Vertices_List, 1).

%Innere Methode von checkDirectOrder(Graph)
checkDirectOder(Graph, Vertices_List, Current_Vertices_Index) -> 
	
	%Abbruchbedinung
	if (Current_Vertices_Index > length(Vertices_List)) ->
		   io:fwrite("Grad ist gerade ;) ");
	true ->
	
	%Aktuelle Vertex ID beschaffen
	Current_Vertex_ID = lists:nth(Current_Vertices_Index, Vertices_List),
	
	%Inzidenten Kanten zur Aktuellen Vertex ID hollen (Liste)
	Incident_TO_Current_Vertex_ID = graph_adt:getIncident(Current_Vertex_ID, Graph),
	
	%Den Grad zur Aktuellen Vertex ID bestimmen
	Current_Order = length(Incident_TO_Current_Vertex_ID),
	
	%Liste mit Inzidenten Kanten auf mod 2 == 0 pruefen, wenn ungleich, dann den Algorithmus stoppen
	if ( Current_Order rem 2 =/= 0 ) ->
		   graph_enthaelt_knoten_mit_ungeraden_grad;
	true -> checkDirectOder(Graph, Vertices_List, Current_Vertices_Index + 1)
	
	end
	
	end.
	
%Prueft ob der Graph zusammen haengend ist
isCompound(Graph) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	
	%Ueber alle ID Iterieren, deren Inzidenten heraus hollen und wenn Ecke keine Inzidenten besitzt,
	%dann den Algorithmus abbrechen
	
	%Alle ID's heraus hollen
	Vertices_List = [ lists:nth(2, X) || X <- Vertices ],	
	
	isCompound(Graph, Vertices_List, 1).

isCompound(Graph, Vertices_List, Current_Vertices_Index) -> 
	%Abbruchbedinung
	if (Current_Vertices_Index > length(Vertices_List)) ->
		   io:fwrite("Graph ist zusammen haengend ;) ");
	true ->
	
	%Aktuelle Vertex ID beschaffen
	Current_Vertex_ID = lists:nth(Current_Vertices_Index, Vertices_List),
	
	%Inzidenten Kanten zur Aktuellen Vertex ID hollen (Liste)
	Incident_TO_Current_Vertex_ID = graph_adt:getIncident(Current_Vertex_ID, Graph),
	
	Size_Incident_To_Current_Vertex_ID = length(Incident_TO_Current_Vertex_ID),
	
	%Liste mit Inzidenten Kanten auf mod 2 == 0 pruefen, wenn ungleich, dann den Algorithmus stoppen
	if ( Size_Incident_To_Current_Vertex_ID =< 0 ) ->
		   graph_ist_nicht_zusammen_haengend;
	true -> isCompound(Graph, Vertices_List, Current_Vertices_Index + 1)
	
	end
	
	end.

%1. Wähle einen beliebigen Knoten v_0 des Graphen und konstruiere von v_0 ausgehend
%   einen Unterkreis K in G, der keine Kante in G zweimal durchläuft.
createUnderCircle(Graph, Random_Vertex_ID, Not_Allowed_Edges, Under_Graph_Vertices_ID, Under_Graph_Vertices_ID_Buffer, Start_Vertex_ID) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	%Random_Vertex_ID ist ein beliebiger Knoten aus Graph

	%Den Weg des Untergraphen abspeichern
	Modify_Under_Graph_Vertices_ID = Under_Graph_Vertices_ID ++ [Random_Vertex_ID],
	
	%Erstmal Alle Kanten zum Aktuellen Knoten ermitteln
	Edges_List = graph_adt:getIncident(Random_Vertex_ID, Graph),
	
	%Alle legitimen Wege ermitteln 
	Legitim_Edges = [ X || X <- Edges_List, (not lists:member(X, Not_Allowed_Edges)) ],
	
	%TODO: Schauen was getann wird, wenn kein legitimer Weg mehr vorhanden ist
	
	
	%Sich einen beliegen Weg (Kante) aussuchen, in unseren Fall immer mit den index 1
	Using_Edge = lists:nth(1, Legitim_Edges),
	
	%Benutze Kante vermerken, dass wir da nicht noch ein mal durch laufen duerfen
	Modify_Not_Allowed_Edges = Not_Allowed_Edges ++ [Using_Edge],
	
	%Jetzt wollen wir den Aktuellen Knoten ermitteln, an den wir von Random_Vertexx_ID angekommen sind
	%Source oder Target ist jetzt das Aktuelle Element (Vertex ID)
	Source_Vertex_ID = element(1, lists:nth(2, Using_Edge)),
	Target_Vertex_ID = element(2, lists:nth(2, Using_Edge)),
	
	Source_Target_List = [Source_Vertex_ID] ++ [Target_Vertex_ID],
	
	%Die aktuelle Vertex ID jetzt ermitteln
	Current_Vertex_ID = lists:nth(1, [ X || X <- Source_Target_List, X =/= Random_Vertex_ID] ),
	
	if ( Start_Vertex_ID =:= Current_Vertex_ID ) ->
		   %TODO: 
		   %Neue Startwerte ermitteln und
		   %hier solange sich selbst auf rufen, bis wir alle Untergraphen haben
		   [ Under_Graph_Vertices_ID_Buffer ++ [Modify_Under_Graph_Vertices_ID ++ [Start_Vertex_ID]], Modify_Not_Allowed_Edges ];
	   	   
	true ->
		io:fwrite("Rekursion"), io:nl(),
		createUnderCircle(Graph, Current_Vertex_ID, Modify_Not_Allowed_Edges, Modify_Under_Graph_Vertices_ID, Under_Graph_Vertices_ID_Buffer, Start_Vertex_ID) 
		
	end.

createUnderCircleVerion_2(Graph, Random_Vertex_ID, Under_Graph_Vertices_ID, Under_Graph_Vertices_ID_Buffer, Start_Vertex_ID) ->
	{ Vertices, EdgesD, EdgesU } = Graph,
	%Random_Vertex_ID ist ein beliebiger Knoten aus Graph

	%Den Weg des Untergraphen abspeichern
	Modify_Under_Graph_Vertices_ID = Under_Graph_Vertices_ID ++ [Random_Vertex_ID],
	
	%Alle legitimen Wege ermitteln 
	Edges_List = graph_adt:getIncident(Random_Vertex_ID, Graph),
	
	%TODO: Schauen was getann wird, wenn kein legitimer Weg mehr vorhanden ist
	%Erstmal provisorisch!
	if ( EdgesU =:= [] ) ->
		   Under_Graph_Vertices_ID_Buffer;
	true ->
	
	%Sich einen beliegen Weg (Kante) aussuchen, in unseren Fall immer mit den index 1
	Using_Edge = lists:nth(1, Edges_List),
	
	%Jetzt wollen wir den Aktuellen Knoten ermitteln, an den wir von Random_Vertexx_ID angekommen sind
	%Source oder Target ist jetzt das Aktuelle Element (Vertex ID)
	Source_Vertex_ID = element(1, lists:nth(2, Using_Edge)),
	Target_Vertex_ID = element(2, lists:nth(2, Using_Edge)),
	
	%Benutze Kante entfernen, den sie darf nicht zwei mal durchlaufen werden
	Modify_Graph = graph_adt:deleteEdge(Source_Vertex_ID, Target_Vertex_ID, Graph),
	
	Source_Target_List = [Source_Vertex_ID] ++ [Target_Vertex_ID],
	
	%Die aktuelle Vertex ID jetzt ermitteln
	Current_Vertex_ID = lists:nth(1, [ X || X <- Source_Target_List, X =/= Random_Vertex_ID] ),
	
	if ( Start_Vertex_ID =:= Current_Vertex_ID ) ->
		   %TODO: 
		   %Mod_U_G_V_G richtig zusammenbauen
			
		   %ID's eines Untergraphen
		   Mod_U_G_V = Modify_Under_Graph_Vertices_ID ++ [Start_Vertex_ID],
		   
		   %Liste der Untergraphen verwalaten
		   Mod_U_G_V_G = Under_Graph_Vertices_ID_Buffer ++ [Mod_U_G_V],
		   
		   %io:write(Mod_U_G_V), io:nl(),
		   
		   Next_Legitim_Vertex_ID = searchNewStartVertex(Modify_Graph, Mod_U_G_V, 1),
		   createUnderCircleVerion_2(Modify_Graph, Next_Legitim_Vertex_ID, [], Mod_U_G_V_G, Next_Legitim_Vertex_ID);
	true ->
		createUnderCircleVerion_2(Modify_Graph, Current_Vertex_ID, Modify_Under_Graph_Vertices_ID, Under_Graph_Vertices_ID_Buffer, Start_Vertex_ID) 
		
	end
	
	end.

%%4. Am ersten Eckpunkt von K, dessen Grad größer 0 ist, lässt man nun einen weiteren Unterkreis K' entstehen, der keine Kante in K durchläuft
%%   und keine Kante in G zweimal enthält.
searchNewStartVertex(Graph, Vertices_ID_List, Index) ->
	
	%Abbruchbedinung
	if ( Index > length(Vertices_ID_List) ) -> 
		kein_weiterer_moeglicher_weg_mehr_erlaubt;
	true -> 
	
	%Alle Kanten zur Aktuellen ID beschaffen
	Edges_List = graph_adt:getIncident(lists:nth(Index, Vertices_ID_List), Graph),
	
	%Grad vom Aktuellen Knoten ermittelt
	Order_From_Current_Vertex = length(Edges_List),
	
	if ( Order_From_Current_Vertex > 0) ->
		%Legitime ID zurueck liefern
		lists:nth(Index, Vertices_ID_List);
	true -> 
		searchNewStartVertex(Graph, Vertices_ID_List, Index + 1)
	end
	
	end.
	



%Prueft ob der Graph, ein Euler Kreis enthaelt:  
%2. Wenn K ein Eulerkreis ist, breche ab. Andernfalls:
isEulerCircle(Graph) -> 

	C = 25.


