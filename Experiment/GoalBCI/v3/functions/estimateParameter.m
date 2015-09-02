function accuracy = estimateParameter(predictor, label)
    % predictor is a trials x channels cell array, where each cell (in the
    % trials dimension) is of variable length.
    
    % label is a trials x 1 cell array, where each cell (in the trials
    % dimension) is of variable length, but matches the lengths of the predictor
    % array
    
    %% the first thing to do is some error checking
    if (~iscell(predictor))
        error ('predictor should be a cell matrix');
    elseif (ndims(predictor) ~= 2)
        error ('predictor should be TRIALS x CHANNELS');
    end
    
    if (length(label) ~= size(predictor, 1))
        error ('unequal number of predictor and label observations (trials)');
    end
    
    %% now let's reshape the predictor and label arrays accordingly
    Ntrials = size(predictor, 1);
    Nchans  = size(predictor, 2);
    
    
    % set up to pre-allocate
    L = sum(cellfun(@(x) length(x), label));
    
    allpredictors = zeros(L, Nchans);
    alllabels = zeros(L, 1);
    
    offset = 1;
    
    for tr = 1:Ntrials
        trialData = [predictor{tr,:}];
        allpredictors(offset:(offset+size(trialData,1)-1), :) = trialData;
        alllabels(offset:(offset+size(trialData,1)-1)) = label{tr};        
        offset = offset+size(trialData,1);
    end
        
    % at this point allpredictors should be sum([length(label{:})]) by
    % Nchans
    
    % alllabels should be sum([length(label{:})]) by 1

    
    [accuracy, estimates, posteriors] = mCrossvalLDA(allpredictors', alllabels, 5, struct);    
    
    
end