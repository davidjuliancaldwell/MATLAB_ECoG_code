%% define constants
addpath ./functions
Z_Constants;

%%

DO_PREROLL = 0;
DO_PLOTS = 0;

%%
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'data', 'fs', 'cchan', 'hemi', 'montage', 'bad_channels');
    
	% for each predictor, determine the lagged version that was most informative
	txts = {'velocity', 'error', 'interaction'};
% 	txts = {'velocity', 'error', 'interaction'};
    
    acorrs = cell(size(txts));
    amaxlag = cell(size(txts));
    apreds = cell(size(txts));
    
    for idx = 1:length(txts)
        txt = txts{idx};
        load(fullfile(META_DIR, ['coding ' txt ' ' subjid '.mat']), 'lags', 'corrs', 'maxlag', 'data', 'paths', 'velocity', 'error', 'interaction', 'derror', 'location', 'tsize','stuck');
        acorrs{idx} = corrs;
        amaxlag{idx} = maxlag;
        
        eval(sprintf('pred = %s;', txt));           
        
        [apreds{idx}, Y, srcs] = reshapeCellPredictors(pred(~stuck)', data(:, ~stuck), lags, DO_PREROLL);
        
    end

%     X = zeros(size(Y,1), length(txts) + 3);
    X = zeros(size(Y,1), length(txts) + 1);

    % add target position
    [dirAdd, ~] = reshapeCellPredictors(location(~stuck)', data(1, ~stuck), [min(lags) lags(lags==0) max(lags)], DO_PREROLL);        
    dirAdd = dirAdd(:,2);            
    
    distAdd = abs(dirAdd-.5);
    
    % take distance out of the directional factor
%     dirAdd = sign(dirAdd-.5);
    
    szAdd = reshapeCellPredictors(tsize(~stuck)', data(1,~stuck), [min(lags) lags(lags==0) max(lags)], DO_PREROLL);        
    szAdd = szAdd(:,2);
    
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
%                     X(:, idx) = apreds{idx}(:, lags==amaxlag{idx}(ch)*fs);
                end

                idx = idx + 1;
            end	

            X(:, idx) = dirAdd;
%             X(:, idx+1) = distAdd;
%             X(:, idx+2) = szAdd;

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
    
    if (DO_PLOTS)
        for d = 1:NPreds
            clear w p;

            figure

            if d >= length(txts)+1
                w = cellfun(@(x) x(d), ts);
                p = cellfun(@(x) x(d), ps);

                % bonf correction
                w(p * length(p) > 0.05) = NaN;

                if (~all(isnan(w)))
                    PlotDotsDirect(subjid, montage.MontageTrodes, w, hemi, [-max(abs(w)) max(abs(w))], 15, 'america', [], false);

                    if (~isnan(w(cchan)))
                        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', 15);
                    else
                        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', 5);
                    end

                    colorbarLabel(colorbar, 't-stat');
                else
                    PlotDotsDirect(subjid, montage.MontageTrodes, w, hemi, [-1 1], 10, 'america', [], false);
                end

                txt = 'target position';
                title([SUBCODES{c} ' ' txt]);
            else
                txt = txts{d};
                load(fullfile(META_DIR, ['coding ' txt ' ' subjid '.mat']), 'lags', 'maxlag');

                func = @(x) x(d);
                incl = cellfun(func, included);
                w = cellfun(func, ts);
                p = cellfun(func, ps);

                p(~incl) = 1;
                w(~incl) = NaN;

                % bonf correction
                w(p * length(p) > 0.05) = NaN;

                maxlag(isnan(w)) = NaN;

                if (~all(isnan(maxlag)))
                    ms = 5+ceil(15*abs(w)/max(abs(w)));
                    PlotDotsDirect(subjid, montage.MontageTrodes, maxlag, hemi, [min(lags)/fs max(lags)/fs], ms, 'america', [], false);
                    if (~isnan(ms(cchan)))
                        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', ms(cchan));
                    else
                        plot3(montage.MontageTrodes(cchan, 1), montage.MontageTrodes(cchan, 2), montage.MontageTrodes(cchan, 3), 'go', 'markersize', 5);
                    end

                    title([SUBCODES{c} ' ' txt ' (max abs t = ' num2str(max(abs(w))) ')']);
                    colorbarLabel(colorbar, 'peak lag (sec) [neg. means brain leads behavior]');
                else
                    PlotDotsDirect(subjid, montage.MontageTrodes, NaN*maxlag, hemi, [0 1], 10, 'america', [], false);
                    title([SUBCODES{c} ' ' txt]);                
                end
            end

            load('america');
            colormap(cm);

            if (strcmp(subjid, 'd6c834'))
                view(-112, 51);
            elseif (strcmp(subjid, '5050b0'))
                view(-38, 32);
            end    

            SaveFig(OUTPUT_DIR, ['regression ' txt ' ' subjid], 'png', '-r150');
        end
    end
    
    save(fullfile(META_DIR, ['regression ' subjid '.mat']), 'ts', 'ps', 'fits', 'included', 'srcs', 'residuals', 'Y', 'amaxlag');
    close all
end
