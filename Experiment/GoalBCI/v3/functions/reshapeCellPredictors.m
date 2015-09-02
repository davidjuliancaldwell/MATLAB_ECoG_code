function [allpredictors, allresponses, sourcetrial] = reshapeCellPredictors(predictor, response, lags, preroll)
    Ntrials = size(predictor, 1);
    Nchans  = size(predictor, 2);    
    
    % set up to pre-allocate
    L = sum(cellfun(@(x) length(x), response(1,:)));
    
    allpredictors = zeros(L, Nchans * length(lags));
    allresponses = zeros(L, size(response, 1));
    sourcetrial = zeros(L, 1);
    
    offset = 1;
    
    mresponse = [];
    
    for tr = 1:Ntrials
        
        trialData = [predictor{tr,:}];
        
        laggedData = lagmatrix(trialData, lags);
        mresponse = cat(2, response{:, tr});
        
        if (preroll)
            % clip the portions of lagged data that correspond to the
            % preroll and postroll
            predrop = 1:sum(lags<0);
            laggedData(predrop, :) = [];
            mresponse(predrop, :) = [];
            
            postdrop = (size(laggedData, 1)-sum(lags>0)+1):size(laggedData, 1);
            laggedData(postdrop, :) = [];
            mresponse(postdrop, :) = [];
        end
        
        allpredictors(offset:(offset+size(laggedData,1)-1), :) = laggedData;
        allresponses(offset:(offset+size(laggedData,1)-1), :) = mresponse;
        sourcetrial(offset:(offset+size(laggedData,1)-1)) = tr;
        
        offset = offset+size(laggedData,1);
    end
    
    if (preroll)
        allpredictors(offset:end,:) = [];
        allresponses(offset:end,:) = [];
        sourcetrial(offset:end,:) = [];
    end
    
    % at this point allpredictors should be sum([length(response{:})]) by
    % Nchans * length(lags)
    
    % allresponses should be sum([length(response{:})]) by the number of
    % response variables included

    % finally, drop all of the time points with NaN values, these would
    % correpond to pre-trial and post-trial brain data anyway... but it
    % does mean that we lose behavior samples at either end of each trial
    % equivalent to the number of positive (on one side) and negative (on
    % the other) lags.
    bads = any(isnan(allpredictors),2);
    allpredictors(bads,:) = [];
    allresponses(bads,:) = [];
    sourcetrial(bads) = [];
end