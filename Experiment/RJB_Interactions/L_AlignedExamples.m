%%
Z_Constants;
addpath ./scripts;

bads = strcmp(SIDS, '38e116');
SIDS(bads) = [];
SCODES(bads) = [];

%% lets build a table of electrode information

showtrodes = [31 32 6 28 15 NaN 63 32 62 38];

resultA = [];
earlyresultA = [];
lateresultA = [];

ctr = 0;
for ctr = 1:length(SIDS)
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject    
    
    load(fullfile(META_DIR, [sid '_results']), 'bas', 'class', 'hmats', 'tlocs');
    load(fullfile(META_DIR, [sid '_extracted']), 'trodes', 't', 'alignedT', 'fs');
    
    tConsidered = t >= 0 & t < 1;
    tAConsidered = alignedT >= -0.502 & alignedT <= 0.5;
    
    controlLocs(ctr, :) = tlocs(trodes(1), :);
    
    %% first, go out and get all the simulation results
    allmaxes = [];
    allmins = [];
    earlymaxes = [];
    earlymins = [];
    latemaxes = [];
    latemins = [];
    
    arrs = [];
    earlyarrs = [];
    earlyarrs2 = [];
    latearrs = [];
    
    for chani = 2:length(trodes)
        chan = trodes(chani);
        
        load(fullfile(META_DIR, sid, [sid '_simulations_' num2str(chan) '.mat']), '*mins*', '*maxes*');
        if (size(maxes, 2) ~= 100 || size(mins, 2) ~= 100)
            warning(sprintf('incorrect number of simulation runs for %s', sid));
        else            
            allmaxes = cat(2, allmaxes, maxes);        
            allmins  = cat(2, allmins, mins);
            
            earlymaxes = cat(2, earlymaxes, maxesEarly);
            earlymins  = cat(2, earlymins,  minsEarly);
            
            latemaxes = cat(2, latemaxes, maxesLate);
            latemins  = cat(2, latemins,  minsLate);
            
%             arrs(:,:,end+1) = max(maxes, abs(mins));
            arrs(:,:,end+1) = maxes;
            earlyarrs(:,:,end+1) = maxesEarly;
            latearrs(:,:,end+1) = maxesLate;
        end
    end       
    
%     % sort out what the thresholds are for this specific subject
    
    lims = max(arrs, [], 3);
    earlylims = max(earlyarrs, [], 3);
    latelims = max(latearrs, [], 3);
    
    for interactionType = 1:size(lims, 1)
        lims(interactionType, :) = sort(lims(interactionType, :), 'descend');
        earlylims(interactionType, :) = sort(earlylims(interactionType, :), 'descend');
        latelims(interactionType, :) = sort(latelims(interactionType, :), 'descend');
    end
    
    % get uncorrected distributions
    arrs = sort(arrs,2,'descend');
    earlyarrs = sort(earlyarrs, 2, 'descend');
    latearrs = sort(latearrs, 2, 'descend');
    
%     uncorr = prctile(abs([allmins allmaxes]), 95, 2);
%     bonf = prctile(lims, 95, 2);
    
    
    %% now, plot the interesting interaction
%     for chani = 2:length(trodes)
    if (~isnan(showtrodes(ctr)))
        chan = showtrodes(ctr);
        
        % ok, a little confusing, but for each channel, we want to ask
        % whether any of the interactions, aligned or not, were
        % significant.  The bootstrapping approach as it's currently
        % written only looks at 1 sec worth of data, so we have to do the
        % same to be fair, when examining real interactions.  In the case
        % of the unaligned interactions, we're going to look at t>=0 & t<1.
        % For the aligned interactions, on the other hand, we're going to
        % look at t_a >= -0.5 & t_b < 0.5.
        
        % now load the interaction data
        load(fullfile(META_DIR, sid, [sid '_interactions_' num2str(chan) '.mat']), 'lags', 'mAlInt*', 'mInt*');
        lags = lags / fs;
                            
        for d = 1
            [weight, tcenter, lcenter] = findBestLag(squeeze(mAlInt(d,:,tAConsidered)), alignedT(tAConsidered), lags, lims(d, 5), false);
            
            resultA(end+1, :) = [...
                ctr ...
                chan ...
                tlocs(chan,1) ...
                tlocs(chan,2) ...
                tlocs(chan,3) ...
                class(chan) ...
                hmats(chan) ...
                bas(chan) ...
                d ...
                pValueForWeight(weight, lims(d, :)) ...
                weight ...
                tcenter ...
                lcenter ...
                ];                        
            
            [weight, tcenter, lcenter] = findBestLag(squeeze(mAlIntEarly(d,:,tAConsidered)), alignedT(tAConsidered), lags, earlyarrs(d, 5, chani), false);
            
            earlyresultA(end+1, :) = [...
                ctr ...
                chan ...
                tlocs(chan,1) ...
                tlocs(chan,2) ...
                tlocs(chan,3) ...
                class(chan) ...
                hmats(chan) ...
                bas(chan) ...
                d ...
                pValueForWeight(weight, earlyarrs(d, :, chani)) ...
                weight ...
                tcenter ...
                lcenter ...
                ];                        
            
            [weight, tcenter, lcenter] = findBestLag(squeeze(mAlIntLate(d,:,tAConsidered)), alignedT(tAConsidered), lags, latearrs(d, 5, chani), false);
            
            lateresultA(end+1, :) = [...
                ctr ...
                chan ...
                tlocs(chan,1) ...
                tlocs(chan,2) ...
                tlocs(chan,3) ...
                class(chan) ...
                hmats(chan) ...
                bas(chan) ...
                d ...
                pValueForWeight(weight, latearrs(d, :, chani)) ...
                weight ...
                tcenter ...
                lcenter ...
                ];                                    
            
            if (d==1 && (resultA(end, 10) <= 0.05))
                lagPlot2(squeeze(mAlInt(d, :, tAConsidered)), (squeeze(mAlInt(d, :, tAConsidered)) >= lims(d, 5)), ...
                        squeeze(mAlIntEarly(d, :, tAConsidered)), (squeeze(mAlIntEarly(d, :, tAConsidered)) >= earlyarrs(d, 5, chani)), ...
                        squeeze(mAlIntLate(d, :, tAConsidered)), (squeeze(mAlIntLate(d, :, tAConsidered)) >= latearrs(d, 5, chani)), ...
                        alignedT(tAConsidered), lags);
                title(SCODES{ctr});
%                 set(gcf, 'pos', [624         474        1250         504]);

                set(get(gca, 'xlabel'), 'fontsize', 18)
                set(get(gca, 'ylabel'), 'fontsize', 18)
                set(gca, 'fontsize', 14)
                set(get(gca, 'title'), 'fontsize', 18)
                get(gcf,'children');               
                set(get(ans(1), 'ylabel'), 'fontsize', 14)
    
%                 SaveFig(OUTPUT_DIR, sprintf('aints_%s_%d', sid, chan), 'png', '-r600');
                SaveFig(OUTPUT_DIR, sprintf('aints_%s_%d', sid, chan), 'eps', '-r600');
                cm = colormap('hot');
                cm = cm(end:-1:1,:);
                colormap(cm);
                SaveFig(OUTPUT_DIR, sprintf('aints_%s_%d_color', sid, chan), 'eps', '-r600');
                close
            end            
        end
    end      
end

