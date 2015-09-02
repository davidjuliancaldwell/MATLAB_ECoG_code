function Y = mCell2mat(X)
    NChans = size(X, 1);
    NObs   = size(X, 2);
    L = max(cellfun(@(x) length(x), X(1,:)));
    
    Y = NaN*zeros(NChans, NObs, L);
    
    for c = 1:NChans
        for o = 1:NObs
            Y(c,o,1:length(X{c,o})) = X{c,o};
        end
    end
end