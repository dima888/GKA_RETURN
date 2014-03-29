%% @author foxhound
%% @doc @todo Add description to graph_parser.


-module(graph_parser).

%% ====================================================================
%% API functions
%% ====================================================================
-export([importGraph/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================

importGraph(Datei, Attr) -> 
	
	FilePath = "C:\\Users\\foxhound\\Desktop\\test2.txt",
	TupleData = file:read_file(FilePath),
	ListDataAlpha = tuple_to_list(TupleData),
	Data = lists:nth(2, ListDataAlpha).