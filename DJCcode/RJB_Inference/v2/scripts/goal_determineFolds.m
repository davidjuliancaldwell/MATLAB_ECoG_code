function fold = goal_determineFolds(labels, n)

    
    %% per each fold, determine the features to be used
    obs = 1:length(labels);
    obsPer = length(labels)/n;
    fold =  ceil(obs / obsPer);
    
    %% randomize
    fold = fold(randperm(length(fold)));
    
    %% make sure that each of the potential labels are represented in each fold
    ulabels = unique(labels);
    
    for c = 1:n
        flabels = labels(fold==c);
        
        if (any(~ismember(ulabels, flabels)))
            error('one or more folds not represented, consider changing N');
        end        
    end
    
end