%%
Z_Constants;
addpath ./scripts;

load(fullfile(META_DIR, 'screened_interactions.mat'), '*resultA');

badsub = [];
badsub = find(strcmp(SIDS, '38e116'));
resultA(ismember(resultA(:,1), badsub), :) = [];
earlyresultA(ismember(earlyresultA(:,1), badsub), :) = [];
lateresultA(ismember(lateresultA(:,1), badsub), :) = [];

% ditch the old ones
resultA(:,14:end) = [];
earlyresultA(:,14:end) = [];
lateresultA(:,14:end) = [];

keeps = resultA(:,9)==1 & resultA(:,10) <= 0.05;
subs = unique(resultA(keeps, 1));

for ctr = subs'
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject    
    
    load(fullfile(META_DIR, [sid '_extracted']), 'alignedT', 'fs');
    tBase = alignedT >= -3 & alignedT <= -2;        
%     tBase = ~isnan(alignedT);
    
    trodes = resultA(keeps & resultA(:,1)==ctr, 2)';
    
    %% now, evaluate all interactions
    for chani = 1:length(trodes)
        chan = trodes(chani);
        
        % ok, a little confusing, but for each channel, we want to ask
        % whether any of the interactions, aligned or not, were
        % significant.  The bootstrapping approach as it's currently
        % written only looks at 1 sec worth of data, so we have to do the
        % same to be fair, when examining real interactions.  In the case
        % of the unaligned interactions, we're going to look at t>=0 & t<1.
        % For the aligned interactions, on the other hand, we're going to
        % look at t_a >= -0.5 & t_b < 0.5.
        
        % now load the interaction data
        load(fullfile(META_DIR, sid, ['all_' sid '_interactions_' num2str(chan) '.mat']), 'alignedInteractions', 'alignedT', 'lags', 'fs', 'early', 'late');
        
        nint = zeros(size(alignedInteractions));
        for e = 1:size(nint, 1)
            nint(e,:,:) = normalizeSTWCMap(alignedInteractions(e,:,:), tBase);
        end

        pts = nint(:,:,alignedT>-.5 & alignedT<.5);
        thresh = min(max(max(pts, [], 3), [], 2));
        
        pts = pts .* double(pts >= thresh);
        
        res = zeros(size(pts, 1), 2);

        for e = 1:size(res, 1)
            res(e, 1) = sum(sum(squeeze(pts(e,lags>0,:))));
            res(e, 2) = sum(sum(squeeze(pts(e,lags<0,:))));
        end
        
        %%% statistical tests
        fx = @(x) binotest(sum(x==1), length(x));        
        
        asign = sign(res(:,1)-res(:,2));
        ap = fx(asign);
        
        esign = sign(res(early,1)-res(early,2));
        ep = fx(esign);
        
        lsign =sign(res(late,1)-res(late,2));
        lp = fx(lsign);

        idx = find(resultA(:, 1) == ctr & resultA(:, 2) == chan & resultA(:, 9) == 1);
        
        resultA(idx, 14) = mean(asign);
        
        if (isnan(resultA(idx, 14)))
            x = 5;
        end
        
        resultA(idx, 15) = ap;
        
        earlyresultA(idx, 14) = mean(esign);
        earlyresultA(idx, 15) = ep;
        
        lateresultA(idx, 14) = mean(lsign);
        lateresultA(idx, 15) = lp;

        
        peaks = max(max(pts, [], 2), [], 3);
        [h, p, ~, stat] = ttest2(peaks(early), peaks(late));
        resultA(idx, 16) = stat.tstat;
        resultA(idx, 17) = p;
        
    end      
end

%% print out a summary
resultA(keeps,:)

fprintf('from all   trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(resultA(keeps, 15) <= 0.05), sum(keeps), sum(resultA(keeps, 15) <= 0.05 & resultA(keeps, 14) > 0), sum(resultA(keeps, 15) <= 0.05 & resultA(keeps, 14) < 0));
fprintf('from early trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(earlyresultA(keeps, 15) <= 0.05), sum(keeps), sum(earlyresultA(keeps, 15) <= 0.05 & earlyresultA(keeps, 14) > 0), sum(earlyresultA(keeps, 15) <= 0.05 & earlyresultA(keeps, 14) < 0));
fprintf('from late  trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(lateresultA(keeps, 15) <= 0.05), sum(keeps), sum(lateresultA(keeps, 15) <= 0.05 & lateresultA(keeps, 14) > 0), sum(lateresultA(keeps, 15) <= 0.05 & lateresultA(keeps, 14) < 0));

% fprintf('from all   trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(resultA(keeps, 14) ~= 0), sum(keeps), sum(resultA(keeps, 14) > 0), sum(resultA(keeps, 14) < 0));
% fprintf('from early trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(earlyresultA(keeps, 14) ~= 0), sum(keeps), sum(earlyresultA(keeps, 14) > 0), sum(earlyresultA(keeps, 14) < 0));
% fprintf('from late  trials there were %d (out of %d) significant lag relationships (%d pos, %d neg)\n', sum(lateresultA(keeps, 14) ~= 0), sum(keeps), sum(lateresultA(keeps, 14) > 0), sum(lateresultA(keeps, 14) < 0));

save(fullfile(META_DIR, 'screened_interactions.mat'), '-append', 'resultA', 'earlyresultA', 'lateresultA');

%% make a table
fh = fopen(fullfile(OUTPUT_DIR, 'lag_table.csv'), 'w');

fprintf(fh, 'SID, TRODE, ALL_MEAN, ALL_P, EARLY_MEAN, EARLY_P, LATE_MEAN, LATE_P\n');

for keepi = find(keeps)'
    fprintf(fh, '%s,%d,%f,%f,%f,%f,%f,%f\n', ...
        SCODES{resultA(keepi, 1)}, ...
        resultA(keepi, 2), ...
        resultA(keepi, 14), ...
        resultA(keepi, 15), ...
        earlyresultA(keepi, 14), ...
        earlyresultA(keepi, 15), ...
        lateresultA(keepi, 14), ...
        lateresultA(keepi, 15));
end

fclose (fh);