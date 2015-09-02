%% define constants
addpath ./functions
Z_Constants;

%%

MIN_LAG_SEC = 1;
MAX_LAG_SEC = 1;
LAG_STEP_SAMPLES = 1;

DO_PREROLL = 0;

%%
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    %% load in data and get set up
    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');
    
    lags = round(-MIN_LAG_SEC*fs) : LAG_STEP_SAMPLES : round(MAX_LAG_SEC*fs);
    if (~ismember(lags, 0))
        error ('innapropriate lag range chosen, doesn''t include zero.');
    end
    
    velocity = cell(size(paths));
    location = velocity;
    error = velocity;
    derror = velocity;
    interaction = velocity;
    tsize = velocity;
    stuck = [];
    
    %% collect kinematic and neural data
    for e = 1:length(paths)
        % collect velocity and error
        velocity{e} = [0; diff(paths{e})];
        error{e}    = diffs{e};
        interaction{e} = velocity{e} .* error{e};
        derror{e}   = abs(diffs{e});
        
        % prune down to just be during the feedback period
        start = find(t > 0, 1, 'first')+2;
        endd = length(error{e})-postDur*fs;

%         % prune down to just be during the first second after RT in
%         % feedback
%         start = find(t > .5, 1, 'first')+2;
%         endd = min(start+fs, length(error{e})-postDur*fs);

%         % prune down to just be everything after the first second of the
%         % trial
%         start = find(t > 1, 1, 'first')+2;
%         endd = length(error{e})-postDur*fs;

        if (DO_PREROLL)
            start = start + min(lags);
            endd = endd + max(lags);
        end
        
        for ch = 1:size(data, 1)
            data{ch, e} = (data{ch, e}(start:endd));
        end
                
        paths{e} = paths{e}(start:endd);  
        
        detectionThreshold = 10; % consecutive samples to be "stuck"
        stuck(e) = max(conv(double(diff(paths{e})==0), ones(detectionThreshold, 1))) == detectionThreshold;
        
%         plot(paths{e});
%         if(stuck(e))
%             title('stuck');
%         else
%             title('notstuck');
%         end
        
        velocity{e} = velocity{e}(start:endd);
        error{e} = error{e}(start:endd);        
        interaction{e} = interaction{e}(start:endd);
        
        derror{e} = derror{e}(start:endd);
%         direction{e} = targetY{e}(start:endd) > .5; % up is 1, down is zero
        location{e} = targetY{e}(start:endd);
        tsize{e} = targetD{e}(start:endd);
        
%         plot(paths{e})
%         ylim([0 1])
%         hline(targetY{e}(end))
%         hline(targetY{e}(end)+targetD{e}(end)/2)
%         hline(targetY{e}(end)-targetD{e}(end)/2)
    end

    %% perform cross-correlation analyses on individual channels/predictors
    % this is in an effort to perform data driven model order selection
    % and to tell us something about the temporal relationships between the
    % predictors and neural data
        
    for sub = {{velocity, 'velocity'}, {paths, 'paths'}, {error, 'error'}, {interaction, 'interaction'}, {derror, 'derror'}}
        qty = sub{1}{1};
        txt = sub{1}{2};
                
        [lQty, lData,src] = reshapeCellPredictors(qty(~stuck)', data(:, ~stuck), lags, DO_PREROLL);
%         [lQty, lData] = reshapeCellPredictors(qty', data, lags, DO_PREROLL);
        [r, p] = corr(lQty, lData);
  
        r(:, bad_channels) = 0;
        p(:, bad_channels) = 1;
        
        sr2 = sign(r) .* r.^2;
   
%         p_allowed = fdr(p, 0.05);
        p_allowed = bonf(p, 0.05);

        %%
        maxlag = zeros(size(data, 1), 1);
        corrs = zeros(size(data, 1), 1);

        test = r.^2.*double(p<=p_allowed);
        
        for ch = 1:size(data, 1)
            if (all(p(:,ch)>p_allowed) || ismember(ch, bad_channels))
                maxlag(ch) = NaN;
                corrs(ch) = NaN;
            else
                maxlag(ch) = lags(test(:,ch)==max(test(:,ch)))/fs;
                corrs(ch) = max(test(:,ch));                                
            end
        end
        
        if (c == 1)
            figure
            plot(lags/fs, r(:,cchan).^2, 'k.-');
            vline(maxlag(cchan),'r'); hold on;
            plot(maxlag(cchan), corrs(cchan), 'ro', 'markersize', 15, 'linew', 2);
            xlabel('Lag');
            ylabel('Correlation coefficient (R^2)');
            title('Lag selection - control channel');
            SaveFig(OUTPUT_DIR, 'lag_ex_ctl', 'png', '-r300');
            SaveFig(OUTPUT_DIR, 'lag_ex_ctl', 'eps', '-r300');
            
            figure
            plot(lags/fs, r(:,3).^2, 'k.-');
            vline(maxlag(3),'r'); hold on;
            plot(maxlag(3), corrs(3), 'ro', 'markersize', 15, 'linew', 2);
            xlabel('Lag');
            ylabel('Correlation coefficient (R^2)');
            title('Lag selection - remote channel');
            SaveFig(OUTPUT_DIR, 'lag_ex_nctl', 'png', '-r300');
            SaveFig(OUTPUT_DIR, 'lag_ex_nctl', 'eps', '-r300');            
        end        
        
        
        save(fullfile(META_DIR, ['coding ' txt ' ' subjid '.mat']), 'lags', 'p', 'p_allowed', 'sr2', 'r', 'corrs', 'maxlag', 'data', 'paths', 'velocity', 'error', 'interaction', 'derror', 'location', 'tsize', 'stuck');

    end
    
    close all
end
