function h = OffsetPlot(X)
    h = figure;
    Xprime = zeros(size(X));
    
    for c = 1:size(X,2)
        Xprime(:,c) = map(X(:,c),min(X(:,c)),max(X(:,c)),c-1,c);
    end
    
    plot(Xprime);
end