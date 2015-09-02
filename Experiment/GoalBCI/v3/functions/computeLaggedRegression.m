function [W, r, R2, f, p] = computeLaggedRegression(predictor, response, lags, regType)
    % predictor is a trials x channels cell array, where each cell (in the
    % trials dimension) is of variable length.
    
    % response is a trials x 1 cell array, where each cell (in the trials
    % dimension) is of variable length, but matches the lengths of the predictor
    % array
    
    % lags is a 1xN or Nx1 vector listing the lags to include in the
    % regression model.  a lag of zero implies synchronicity between predictor
    % and response, a positive lag implies that the reponse lags the predictor
    % and a negative lag implies that the response leads the predictor.
    
    % regType can be 'lasso' or anything else.  If not 'lasso', this script
    % will run simple regression, otherwise, it will run cross-validated
    % lasso regression, which is very slow.  Also,it doesn't give the
    % correct stats as outputs.
    
    % W is a channels x lags matrix with the regression coefficients.
    % r is the residual, [CURRENTLY NOT CALCULATED, or at least not organized in a useful format] 
    % R2 is the R2 coefficient for the model
    % f is the f-statistic for the model
    % p is the p value for the the model
    
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
    reshapeCellPredictors(predictor, response, lags);
    
    %% as a temporary, let's do some normalization of the predictors
    allpredictors = zscore(allpredictors);
    
    %% now perform regression    
    if (strcmp(regType, 'lasso'))
        [B, FitInfo] = lasso(allpredictors, allresponses, 'CV', 5);
        W = B(:, FitInfo.IndexMinMSE);
        W = reshape(W, Nchans, length(lags));

        % fakeout
        R2 = 0;
        f = 0;
        p = 0;
        r = cell(size(response));
        
    elseif (strcmp(regType, 'pearson'))
        R = zeros(size(allpredictors, 2), 1);
        p = R;
        
        for pi = 1:size(allpredictors, 2)
            [R(pi), p(pi)] = corr(allpredictors(:, pi), allresponses);
        end
        
        R(p>0.05) = 0;
        
        W = reshape(R, Nchans, length(lags));
        
        % fakeout
        R2 = 0;
        f = 0;
        p = 0;
        r = cell(size(response));
        
    else % simultaneous               
        [W, W_int, r_temp, ~, stats] = regress(allresponses, [ones(size(allpredictors, 1), 1), allpredictors]);             
        
        W(~(sign(W_int(:,1))==sign(W_int(:,2))))=0; % eliminate the poor predictors
        W(1) = []; % drop the constant term
        
        
        W = reshape(W, Nchans, length(lags));
        R2 = stats(1);
        f = stats(2);
        p = stats(3);            
        
        r = cell(size(response));
        for tr = unique(sourcetrial)'
            r{tr} = r_temp(sourcetrial==tr);
        end         
    end    
    
   
end