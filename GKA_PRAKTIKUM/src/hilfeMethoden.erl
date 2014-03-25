%% @author Flah
%% @doc @todo Add description to hilfeMethoden.


-module(hilfeMethoden).

%% ====================================================================
%% API functions
%% ====================================================================
-export([sucheNachAtom/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
sucheNachAtom(Atom, Tupel) 
  when not is_atom(Atom), not is_tuple(Tupel) -> false;
sucheNachAtom(Atom, {_, _, {AttrName, AttrVal}}) ->
	if 
		Atom == AttrName -> AttrVal; 
					true -> nil
	end.
