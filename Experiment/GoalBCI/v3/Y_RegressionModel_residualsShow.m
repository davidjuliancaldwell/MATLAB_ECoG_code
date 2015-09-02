%% define constants
addpath ./functions
Z_Constants;

%%
alllocs = [];
allweights = [];
allsources = [];

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    %% load in data and get set up
    fprintf ('processing %s: \n', subcode);
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'fs', 'cchan', 'hemi', 'montage', 'bad_channels', 'targets');    
    load(fullfile(META_DIR, ['residuals' subjid '.mat']), 'outcomes', 'predictors', 'lags', 'coeffs', 'mses', 'predictions', 'stats', 'residuals', 'srctrial', ...
        'MAX_LAG_SEC', 'LAG_STEP_SAMPLES', 'DO_PREROLL', 'DECIMATE_FAC', 'DF_MAX', 'N_FOLDS');

    %% get all the trial data
    L = max(arrayfun(@(x) sum(srctrial==x), unique(srctrial)));
    
    trials = nan(size(residuals, 2), L, length(targets));
    
    for tr = unique(srctrial)'
        idxs = find(srctrial==tr);            
        trials(:, 1:length(idxs), tr) = residuals(idxs, :)';
    end
    
    %%
    [nx, ny] = subplotDims(size(residuals, 2));
    
    figure
    for ch = 1:size(residuals, 2)
        if (~ismember(ch, bad_channels))
            subplot(nx, ny, ch);
            prettyline((1:L)/fs, squeeze(trials(ch, :, :)), ismember(targets, UP), 'rb');
        end
    end    
end
