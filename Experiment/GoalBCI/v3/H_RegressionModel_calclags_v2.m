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

        for ch = 1:size(data, 1)
            data{ch, e} = (data{ch, e}(start:endd));
        end
                
        paths{e} = paths{e}(start:endd);  
        
        detectionThreshold = 10; % consecutive samples to be "stuck"
        stuck(e) = max(conv(double(diff(paths{e})==0), ones(detectionThreshold, 1))) == detectionThreshold;
        
        velocity{e} = velocity{e}(start:endd);
        error{e} = error{e}(start:endd);        
        interaction{e} = interaction{e}(start:endd);
        
        derror{e} = derror{e}(start:endd);
%         direction{e} = targetY{e}(start:endd) > .5; % up is 1, down is zero
        location{e} = targetY{e}(start:endd);
        tsize{e} = targetD{e}(start:endd);        
    end

    %% perform cross-correlation analyses on individual channels/predictors
    % this is in an effort to perform data driven model order selection
    % and to tell us something about the temporal relationships between the
    % predictors and neural data
        
    for sub = {{velocity, 'velocity'}, {error, 'error'}, {interaction, 'interaction'}, {derror, 'derror'}}
        qty = sub{1}{1};
        txt = sub{1}{2};
                
        [lQty, lData] = reshapeCellPredictors(qty(~stuck)', data(:, ~stuck), [min(lags) 0 max(lags)], false);
        lQty = lQty(:, 2);
        
        lData = zscore(lData);
        
        % determine chance levels
        cC = zeros(100, size(lData, 2));
        ml = max(abs(lags));        
        h = waitbar(0, 'performing chance bootstrap analyses');
        for N = 1:100
            waitbar(N/100, h);
            sq = shuffle(lQty);
            for ch = 1:size(lData, 2)            
                cC(N,ch) = max(xcorr(lData(:,ch), sq, ml, 'coeff').^2);
            end
        end
        close (h);
        
        r = [];
        for ch = 1:size(lData, 2)
            r(:, ch) = xcorr(lData(:, ch), lQty, ml, 'coeff');
        end
                
        r2 = r.*r;
        sr2 = sign(r).*r2;
        
        % calculate p values
        p_allowed = 0.05;        

        % bonf approach
        chance = max(cC,[],2);        
        % uncoff
%         chance = cC(:);

        p = ones(size(r2));
        for z = 1:numel(r2)
            p(z) = mean(r2(z)<chance);
        end
        

%         figure;
%         imagesc(1:size(lData,2), lags,  r2 .* double(p<=p_allowed));
%         title([subjid ' ' txt]);
%         colorbar;
%         hold on;
        
        % for each channel calculate corrs and maxlag values
        for ch = 1:size(lData, 2)
            keeps = p(:,ch) <= p_allowed;
            if (any(keeps) && ~ismember(ch, bad_channels))
                corrs(ch) = max(r2(:,ch).*double(keeps));
                maxlag(ch) = lags(corrs(ch)==r2(:,ch))/fs;
%                 plot(ch, maxlag(ch), 'k.', 'markersize', 20);
            else
                maxlag(ch) = NaN;
                corrs(ch) = NaN;
                
                
            end                        
        end  
        
        save(fullfile(META_DIR, ['coding ' txt ' ' subjid '.mat']), 'lags', 'p', 'p_allowed', 'sr2', 'r', 'corrs', 'maxlag', 'data', 'paths', 'velocity', 'error', 'interaction', 'derror', 'location', 'tsize', 'stuck');

    end
    
    close all
end
