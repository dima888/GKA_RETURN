Hinweiss: Es ist ein Eclipse Projekt, wobei man könnte auch die liegenden Datein in scr auch mit Erlang starten.

Anleitung zum Bellman & Ford, sowie Floyd & Warshall 
1) Graph mit unseren Parser (graph_parser.erl) einlesen mit der Methode importGraph(Datei, Attr),
   oder den Graph selber mit der graph_adt.erl erstellen. 

2) Auf bellman_ford.erl oder floyd_warshall.erl die methode startAlgorithm(Grpah, Source_ID, Target_ID) 
   aufrufen und dann bekommt man die optimale Route zwischen Zwei Knoten heraus. 