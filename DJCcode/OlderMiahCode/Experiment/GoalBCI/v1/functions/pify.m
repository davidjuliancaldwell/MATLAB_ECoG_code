function Y = pify(X)
    [Xs, ind] = sort(X);
    pAdd = (1:length(Xs)) / length(Xs);
    Y = pAdd(ind);    
end