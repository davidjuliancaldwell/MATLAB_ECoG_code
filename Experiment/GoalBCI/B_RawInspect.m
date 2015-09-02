%% define constants
addpath ./functions
Z_Constants;

%%
warning ('subjects are hardcoded');

% recently done 4/5
for c = 10:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);

    files = goalDataFiles(subjid);
    trialStarts = [];
    trialEnds = [];
    trialFiles = [];
    data = [];
    
    for fileIdx = 1:length(files)
        fprintf('  file %d of %d\n', fileIdx, length(files));

        [sig, sta, par] = load_bcidat(files{fileIdx}); 
%         sig = ReferenceCAR(size(sig, 2), [], double(sig));
        
        fs = par.SamplingRate.NumericValue;
        
        [restStarts, restEnds, tgtStarts, ~, ~, holdEnds, fbStarts, fbEnds] = ...
            identifyFullEpochs(sta, par);
                
        if (max(fbEnds-restStarts) + restStarts(end) > size(sig, 1))
            L = max(fbEnds-restStarts) + restStarts(end);
            sig = cat(1, sig, zeros(L-size(sig, 1)+1, size(sig, 2)));
        end
        
        data = cat(3, data, getEpochSignal(sig, restStarts, max(fbEnds-restStarts)+restStarts));
                
        trialStarts = cat(2, trialStarts, restStarts);
        trialEnds = cat(2, trialEnds, fbEnds);
        trialFiles = cat(2, trialFiles, fileIdx * ones(size(restStarts)));
        
    end
    
    t = (1:size(data, 1))/fs;
    
    channel_inspector(data, t, fs);
    
    fprintf('you have to run the last three lines of this script manually\n');
    return
    
    load('bad_trials.mat');
    save(fullfile(META_DIR, sprintf('%s-trial_info.mat', subjid)), 'trialStarts', 'trialEnds', 'trialFiles', 'bad_channels', 'bad_marker');
    
    delete('bad_trials.mat');
    
end 

