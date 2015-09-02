% X =  repmat((1:32)', [1, 20, 50]);
% Y = linToGrid(X, 1);
X =  repmat((1:32), [20, 1, 50]);
Y = linToGrid(X, 2);
size(X)
size(Y)

Xprime = gridToLin(Y, 2:3);