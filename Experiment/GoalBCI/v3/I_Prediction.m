%% define constants
addpath ./functions
Z_Constants;

%%

MIN_LAG_SEC = 1;
MAX_LAG_SEC = 1;
LAG_STEP_SAMPLES = 1;

DO_PREROLL = 0;

%%
txts = {'velocity', 'error', 'interaction'};
NADDS = 1;

weights = cell(length(txts) + NADDS, 1);
locs =    cell(length(txts) + NADDS, 1);
srcs =    cell(length(txts) + NADDS, 1);
bas =     cell(length(txts) + NADDS, 1);
hmats =   cell(length(txts) + NADDS, 1);
zlags =    cell(length(txts) + NADDS, 1);

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
        
    acorrs = cell(size(txts));
    amaxlag = cell(size(txts));
    apreds = cell(size(txts));
    
    for idx = 1:length(txts)
        
        txt = txts{idx};
        eval(sprintf('qty = %s;', txt));
                
        [lQty, lData,src] = reshapeCellPredictors(qty(~stuck)', data(:, ~stuck), lags, false);
        apreds{idx} = lQty;
        
        [r, p] = corr(lQty, lData);
  
        r(:, bad_channels) = 0;
        p(:, bad_channels) = 1;
        
        sr2 = sign(r) .* r.^2;
   
        p_allowed = bonf(p, 0.05);

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
        
        amaxlag{idx} = maxlag;
        acorrs{idx} = corrs;
    end
    
    %% perform multiple regression analyses
    % add target position
    [dirAdd, Y, ~] = reshapeCellPredictors(location(~stuck)', data(:, ~stuck), [min(lags) lags(lags==0) max(lags)], 0);        
    dirAdd = dirAdd(:,2);            
    
    % take distance out of the directional factor
    dirAdd = sign(dirAdd-.5);
    
	% for each predictor, determine the lagged version that was most informative
    X = zeros(size(Y,1), length(txts) + 1);
    
    clear included fits ts ps;    
    clear residuals ys;
    
    bar = waitbar(0, 'performing multiple regression on all channels');
    for ch = 1:size(data, 1)
        if (~ismember(ch, bad_channels))
            waitbar((ch-1)/size(data, 1), bar);

            idx = 1;
            for ztxt = txts
                txt = ztxt{:};
                
                if isnan(amaxlag{idx}(ch))                                            
                    X(:, idx) = nan(size(Y, 1), 1);
                else
                    X(:, idx) = apreds{idx}(:, abs(lags-amaxlag{idx}(ch)*fs) < 0.001);
                end

                idx = idx + 1;
            end	

            X(:, idx) = dirAdd;
            NPreds = size(X, 2);            
            
            included{ch} = ~any(isnan(X),1);

            if (any(included{ch}))                
                fits{ch} = LinearModel.fit(X(:, included{ch}),Y(:,ch));                        
                ts{ch} = zeros(NPreds, 1);                
                ts{ch}(included{ch}) = fits{ch}.Coefficients.tStat(2:end); % drop the constant
                
                ps{ch} = ones(NPreds, 1);
                ps{ch}(included{ch}) = fits{ch}.Coefficients.pValue(2:end);
                
                residuals(:, ch) = Y(:,ch)-fits{ch}.Fitted;
            else
                included{ch} = false(1, NPreds);
                fits{ch} = struct;
                ts{ch} = zeros(NPreds, 1);
                ps{ch} = ones(NPreds, 1);   
                residuals(:, ch) = Y(:,ch);
            end
        else
            included{ch} = false(1, NPreds);
            fits{ch} = struct;
            ts{ch} = zeros(NPreds, 1);
            ps{ch} = ones(NPreds, 1);
            residuals(:, ch) = Y(:,ch);
        end
    end    
    close (bar); clear bar;

    %% now do some estimation
    % for sub 1, ch 41 looks interesting
    ch = 41;
    
    B0 = fits{ch}.Coefficients.Estimate(1);
    Bv = 0; Be = 0; Bi = 0; Bp = 0;
    thresh = 0.05;
    idxs = (cumsum(included{43}) + 1);
    if (included{ch}(1) && ps{ch}(1) < thresh)
        Bv = fits{ch}.Coefficients.Estimate(idxs(1));
    end
    if (included{ch}(2) && ps{ch}(2) < thresh)
        Be = fits{ch}.Coefficients.Estimate(idxs(2));
    end
    if (included{ch}(3) && ps{ch}(3) < thresh)
        Bi = fits{ch}.Coefficients.Estimate(idxs(3));
    end
    if (included{ch}(4) && ps{ch}(4) < thresh)
        Bp = fits{ch}.Coefficients.Estimate(idxs(4));
    end
    
    Phat = Y(:,ch) - B0 - Bv*
    for ch = 1:size(data, 1)
        if (ps{ch}(4) < 7.8125e-4)
            fprintf('hi: %d.\n', ch);
        end            
    end
end
