-module(percep).
-compile(export_all).

start(N) ->
	buildData(N, [], []).

buildData(0, X, Y) ->
	run(X, Y);
buildData(N, [], []) ->
	buildData(N-1, [rand:uniform(100)], [rand:uniform(100)]);
buildData(N, X, Y) ->
	buildData(N-1, X++[rand:uniform(100)], Y++[rand:uniform(100)]).

run([], [], W1, W2, B) ->
	{W1, W2, B};
run([X|Xs], [Y|Ys], W1, W2, B) ->
	{W12, W22, B2} = perceptron(W1, W2, B, X, Y),
	run(Xs, Ys, W12, W22, B2).
run([X|Xs], [Y|Ys]) ->
	{W1, W2, B} = perceptron(rand:uniform(), rand:uniform(), rand:uniform(), X, Y),
	run(Xs, Ys, W1, W2, B).

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