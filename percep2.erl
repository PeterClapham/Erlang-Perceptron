-module(percep2).
-compile(export_all).

test(N) ->
	{Time, {W1, W2, B}} = timer:tc(percep2, start, [N]),
	io:fwrite("Time took: ~b mics~n", [Time]),
	Error = (abs(1 - abs(W1/W2))/100 + abs(B)/100)/2,
	io:fwrite("Average error: ~e%~n", [Error]).

start(N) ->
	spawn(?MODULE, buildData, [N div 2, [], [], self()]),
	spawn(?MODULE, buildData, [N div 2, [], [], self()]),
	receive
		{Wx1, Wy1, B1} -> 
			receive 
				{Wx2, Wy2, B2} ->
					{(Wx1+Wx2)/2, (Wy1+Wy2)/2, (B1+B2)/2}
			end
	end.

buildData(0, X, Y, Pid) ->
	run(X, Y, Pid);
buildData(N, [], [], Pid) ->
	buildData(N-1, [rand:uniform(100)], [rand:uniform(100)], Pid);
buildData(N, X, Y, Pid) ->
	buildData(N-1, X++[rand:uniform(100)], Y++[rand:uniform(100)], Pid).

run([], [], W1, W2, B, Pid) ->
	Pid!{W1, W2, B};
run([X|Xs], [Y|Ys], W1, W2, B, Pid) ->
	{W12, W22, B2} = perceptron(W1, W2, B, X, Y),
	run(Xs, Ys, W12, W22, B2, Pid).
run([X|Xs], [Y|Ys], Pid) ->
	{W1, W2, B} = perceptron(rand:uniform(), rand:uniform(), rand:uniform(), X, Y),
	run(Xs, Ys, W1, W2, B, Pid).

perceptron(W1, W2, B, X, Y) ->
	Exp = heavy(W1*X + W2*Y + B),
	case compareOuts(biggerThan(X, Y), Exp) of
		pos -> rosen(W1, W2, B, X, Y, pos);
		neg -> rosen(W1, W2, B, X, Y, neg);
		null -> {W1, W2, B}
	end.

heavy(In) when In > 0 -> 1;
heavy(_) -> 0.

compareOuts(N, M) when N =:= M -> null;
compareOuts(N, M) when N < M -> pos;
compareOuts(_, _) -> neg.

rosen(W1, W2, B, X, Y, Ord) ->
	Alpha = rand:uniform()/10,
	case Ord of 
		neg -> {W1 + X*Alpha, W2 + Y*Alpha, B + Alpha};
		pos -> {W1 - X*Alpha, W2 - Y*Alpha, B - Alpha}
	end.

biggerThan(X, Y) when X > Y -> 1;
biggerThan(_, _) -> 0.