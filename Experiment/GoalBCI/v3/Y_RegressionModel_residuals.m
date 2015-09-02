%% define constants
addpath ./functions
Z_Constants;

%%

MAX_LAG_SEC = .70;
LAG_STEP_SAMPLES = 3;

DO_PREROLL = 1;

DECIMATE_FAC = 3;
% DECIMATE_FAC = 10;
DF_MAX = 10;

% N_FOLDS = 5;
N_FOLDS = 10;

%%
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    %% load in data and get set up
    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');
    
    lags = floor(-MAX_LAG_SEC*fs) : LAG_STEP_SAMPLES : ceil(MAX_LAG_SEC*fs);
    
    if (~ismember(0, lags))
        error('this code will fail because there is no lag of zero');
    end
    
    velocity = cell(size(paths));
    direction = velocity;
    error = velocity;
    derror = velocity;
    
    %% collect kinematic and neural data
    for e = 1:length(paths)
        % collect velocity and error
        velocity{e} = [0; diff(paths{e})];
        error{e}    = abs(diffs{e});
        derror{e}   = [0; diff(abs(diffs{e}))];
        
        % prune down to just be during the feedback period        
        start = find(t > 0, 1, 'first')+2;
        endd = length(error{e})-postDur*fs;
        
        if (DO_PREROLL)
            start = start + min(lags);
            endd = endd + max(lags);
        end
        
        for ch = 1:size(data, 1)
            data{ch, e} = (data{ch, e}(start:endd));
        end
                
        paths{e} = paths{e}(start:endd);        
        velocity{e} = velocity{e}(start:endd);
        error{e} = error{e}(start:endd);        
        derror{e} = derror{e}(start:endd);
%         direction{e} = targetY{e}(start:endd) > .5; % up is 1, down is zero
        direction{e} = targetY{e}(start:endd);
    end

    %% perform simultaneous lasso regression on a channel-by-channel basis
    % this is in an effort to perform data driven model order selection
    % and to tell us something about the temporal relationships between the
    % predictors and neural data
        
    % step 1 is to build a predictor matrix that will be used in all
    % subsequent regressions.
    
    predictors = [];
    
    txts = {{velocity, 'velocity'}};
    for sub = txts
        qty = sub{1}{1};
        txt = sub{1}{2};
                
        [mpred, outcomes, srctrial] = reshapeCellPredictors(qty', data, lags, DO_PREROLL);                        
        predictors = cat(2,predictors,mpred);
    end
    
    predictors = zscore(predictors);
    outcomes = log(outcomes);
    
    % step 2, on a channel by channel basis, perform lasso regression
    
    coeffs = zeros(length(lags)*length(txts), size(data, 1));
    mses = zeros(1, size(data, 1));
    
    if (DECIMATE_FAC > 1)
        outcomes = outcomes(1:DECIMATE_FAC:end, :);
        predictors = predictors(1:DECIMATE_FAC:end, :);
        srctrial = srctrial(1:DECIMATE_FAC:end);
    end
    
    predictions = 0*outcomes;
    residuals = 0*outcomes;
    
    stats = zeros(size(data,1), 2);
    
    for ch = 1:size(data, 1)
        if (~ismember(ch, bad_channels))
            
            [B, fitInfo] = lasso(predictors, outcomes(:,ch), 'CV', N_FOLDS, 'DFMax', DF_MAX);            
            bestfit = find(fitInfo.Lambda == fitInfo.LambdaMinMSE);            
            coeffs(:, ch) = B(:, bestfit);
            
            if (any(B(:,bestfit)))
                predictions(:,ch) = B(:,bestfit)' * predictors';
                residuals(:,ch) = outcomes(:,ch)-predictions(:,ch);
                
                [stats(ch, 1), stats(ch, 2)] = corr(outcomes(:,ch), predictions(:,ch));
                
                fprintf('!');
            else
                residuals(:,ch) = outcomes(:,ch);
                fprintf('.');                
            end
            
            mses(ch) = fitInfo.MSE(bestfit);
        else
            coeffs(:, ch) = 0;
            
            normalized = zscore(outcomes(:,ch));
            mses(ch) = mean((normalized-mean(normalized)).^2);
            fprintf('.');
        end
    end
    
    fprintf('\n');

    % step 3, visualize and save out results
    save(fullfile(META_DIR, ['residuals' subjid '.mat']), 'outcomes', 'predictors', 'lags', 'coeffs', 'mses', 'predictions', 'stats', 'residuals', 'srctrial', ...
        'MAX_LAG_SEC', 'LAG_STEP_SAMPLES', 'DO_PREROLL', 'DECIMATE_FAC', 'DF_MAX', 'N_FOLDS');

    close all
end
