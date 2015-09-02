function W = computeLaggedRegressionBootstrap(predictor, response, lags, N)    
    % predictor is a trials x channels cell array, where each cell (in the
    % trials dimension) is of variable length.
    
    % response is a trials x 1 cell array, where each cell (in the trials
    % dimension) is of variable length, but matches the lengths of the predictor
    % array
    
    % lags is a 1xN or Nx1 vector listing the lags to include in the
    % regression model.  a lag of zero implies synchronicity between predictor
    % and response, a positive lag implies that the reponse lags the predictor
    % and a negative lag implies that the response leads the predictor.
    
    % N is the number of simulations to run
    
    % W is a channels x lags x N matrix with the regression coefficients.
    
    %% the first thing to do is some error checking
    if (~iscell(predictor))
        error ('predictor should be a cell matrix');
    elseif (ndims(predictor) ~= 2)
        error ('predictor should be TRIALS x CHANNELS');
    end
    
    if (length(response) ~= size(predictor, 1))
        error ('unequal number of predictor and response observations (trials)');
    end
    
    if (~isrow(lags) && ~iscol(lags))
        error ('lags should be a vector');
    end
    
    % error check for consistent predictor size
    
    %% now let's reshape the predictor and response arrays accordingly
    Ntrials = size(predictor, 1);
    Nchans  = size(predictor, 2);
    
    
    % set up to pre-allocate
    L = sum(cellfun(@(x) length(x), response));
    
    allpredictors = zeros(L, Nchans * length(lags));
    allresponses = zeros(L, 1);
    
    offset = 1;
    
    for tr = 1:Ntrials
        trialData = [predictor{tr,:}];
        
        laggedData = lagmatrix(trialData, lags);
        allpredictors(offset:(offset+size(laggedData,1)-1), :) = laggedData;
        allresponses(offset:(offset+size(laggedData,1)-1)) = response{tr};
        
        offset = offset+size(laggedData,1);
    end
    
    
    % at this point allpredictors should be sum([length(response{:})]) by
    % Nchans * length(lags)
    
    % allresponses should be sum([length(response{:})]) by 1

    % finally, drop all of the time points with NaN values, these would
    % correpond to pre-trial and post-trial brain data anyway... but it
    % does mean that we lose behavior samples at either end of each trial
    % equivalent to the number of positive (on one side) and negative (on
    % the other) lags.
    bads = any(isnan(allpredictors),2);
    allpredictors(bads,:) = [];
    allresponses(bads) = [];
    
    %% now perform regression    
    W = zeros(Nchans, length(lags), N);
    
    % do some preparation to speed things up
    X = mat2cell(allpredictors, size(allpredictors, 1), ones(1, size(allpredictors, 2)))';
    SX = cell(length(X), 1);
    
    for c = 1:length(X)
        SX{c} = std(X{c});
        X{c} = X{c} - mean(X{c});
    end
    
    muy = mean(allresponses);
    sigy = std(allresponses);
        
    h = waitbar(0, 'computing bootstrap regressions');
    
    for n = 1:N
        if (mod(n, 10)==0)
            waitbar(n/N, h);
        end
        
        y = allresponses(randperm(length(allresponses)));
%         y = shuffle(allresponses);

        R = cellfun(@(x, sigx) mean(x.*(y-muy))/(sigx*sigy), X, SX);
                
        W(:,:,n) = reshape(R, Nchans, length(lags));
        
%         % test
%         Rtest = zeros(size(R));
%         for chan = 1:size(allpredictors, 2)
%             Rtest(chan) = corr(allpredictors(:,chan), y);
%         end
%         
%         scatter(R, Rtest); hold all
    end
    
    close (h);
end