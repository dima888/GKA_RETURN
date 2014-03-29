%% @author foxhound
%% @doc @todo Add description to graph_parser.


-module(graph_parser).

%% ====================================================================
%% API functions
%% ====================================================================
-export([importGraph/2, readlines/1, costImport/1, costDirektedImport/4]).



%% ====================================================================
%% Internal functions
%% ====================================================================
%TODO: FilePath verlagern || FilePath = Datei
importGraph(Datei, Attr) when Attr == "cost" ->	
	costImport(Datei).
	 
%---------- HILFS FUNKTION ------------
costImport(Datei) -> 
	Graph = graph_adt:new_AlGraph(),
	%Datei = "C:\\Users\\foxhound\\Desktop\\test.txt",
	
	{ok, Device} = file:open(Datei, [read]),
	
	%Erste Zeile, wo angegeben wird ob es gerichtet oder ungerichtet ist
	Row = io:get_line(Device, []),
	
	%Unsere IDs fangen bei 1 an, hier 0, da es in der verarbeitung so angegeben wird: V_ID++
	if Row == "#gerichtet\n" -> costDirektedImport(Datei, Graph, 0, Device);
	   true -> constUndirektedImport(Datei)
	end.

%---------- HILFS FUNKTION ------------
costDirektedImport(Datei, Graph, V_ID, Device) ->

	%FilePath = "C:\\Users\\foxhound\\Desktop\\test.txt",
	%{ok, Device} = file:open(Datei, [read]),
	%%Row = io:get_line(Device, []),
	Row = io:get_line(Device, []),
	
	PartGraph = string:tokens(Row, ", \n "),
	
	%Alle Attribute aus der Textdatei raus hollen
	SourceValName = lists:nth(1, PartGraph),
	TargetValName = lists:nth(2, PartGraph),
	CoustVal = lists:nth(3, PartGraph),

	%Hier kommen die Pruefungen ob die IDs in den Graphen rein duerfen
	BoolValVertexFirst = includeValue(SourceValName, Graph),
	BoolValVertexSecond = includeValue(TargetValName, Graph),
 	
	if BoolValVertexFirst - >
		   ID = V_ID ++,
		   graph_adt:addVertex(ID, Graph);
	   BoolValVertexSecond -> 
		   ID2 = V_ID + 2,
		   graph_adt:addVertex(ID2, Graph);
	   true -> nil
	end.
	


	

	%Graph wird befuelt
	
	
	
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