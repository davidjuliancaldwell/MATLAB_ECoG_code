%%
Z_Constants;
addpath ./scripts

%%
% from felix
bplvtrodes = zeros(size(SIDS, 2), 2);

% subject 0dd118 channel 55 -> 20
bplvtrodes(strcmp(SIDS, '0dd118'), :) = [55 20];

% subject 3745d1 channel 14 -> 46
bplvtrodes(strcmp(SIDS, '3745d1'), :) = [14 46];

% subject 4568f4 channel 46 -> 45
bplvtrodes(strcmp(SIDS, '4568f4'), :) = [46 45];

% subject 58411c channel 40 -> 46
bplvtrodes(strcmp(SIDS, '58411c'), :) = [40 46];

% subject 7662c2 channel 54 -> 15
bplvtrodes(strcmp(SIDS, '7662c2'), :) = [54 15];

% subject 7ee6bc channel 46 -> 35
bplvtrodes(strcmp(SIDS, '7ee6bc'), :) = [46 35];

% subject f83dbb channel 61 -> 36
bplvtrodes(strcmp(SIDS, 'f83dbb'), :) = [61 36];

% subject fc9643 channel 24 -> 54
bplvtrodes(strcmp(SIDS, 'fc9643'), :) = [24 54];

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), 'resultA');
badsub = find(strcmp(SIDS, '38e116'));
resultA(ismember(resultA(:, 1), badsub), :) = [];

keeps = (resultA(:,10)  <= 0.05 & resultA(:, 9)==1);
resultA = resultA(keeps, :);

%% plot all significant interactions on a single brain
figure
PlotCortex('tail', 'r', [], .7); hold on;

bplvDist = NaN*ones(size(SIDS));
stwcDist = NaN*ones(size(SIDS));
distfunc = @(x,y) sqrt(sum((x-y).^2, 2));
   
for sIdx = 1:length(SIDS)
    subjid = SIDS{sIdx};
    load(fullfile(META_DIR, [subjid '_epochs.mat']), 'cchan', 'montage');

    locs = projectToHemisphere(trodeLocsFromMontage(subjid, montage, true), 'r');
    
    % ctl trode
    bPLVFrom = bplvtrodes(sIdx, 1);
    bPLVTo   = bplvtrodes(sIdx, 2);
    
    if (~isempty(find(resultA(:, 1)==sIdx)) || bPLVFrom ~=0)
        PlotDotsDirect('tail', locs(cchan, :)+[5 0 0], 0, 'r', [-1 1], 20, 'america', [], false, true);
    end
        
    if bPLVFrom ~= 0 % we have a bPLV interaction
        if (bPLVFrom ~= cchan && bPLVTo ~= cchan)
            warning('bPLV from/to channel does not equal the control channel fo %s', subjid);
        end
        
        bPLVFromLoc = locs(bPLVFrom, :);
        bPLVToLoc   = locs(bPLVTo,   :);
        
        % bplv trode
        PlotDotsDirect('tail', bPLVToLoc+[5 0 0], 1, 'r', [-1 1], 10, 'america', [], false, true);        
%         PlotInteractions(bPLVFromLoc+[5 0 0], bPLVToLoc+[5 0 0], 1);
        
        % save these for later
        bplvDist(sIdx) = distfunc(bPLVFromLoc, bPLVToLoc);        
    end     
    
    stwcLoc = projectToHemisphere(resultA(resultA(:, 1) == sIdx, 3:5), 'r');

    if (~isempty(stwcLoc))
        % stwc trode
        PlotDotsDirect('tail', stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), -1*ones(1, size(stwcLoc, 1)), 'r', [-1 1], 10, 'america', [], false, true);
        stwcDist(sIdx) = median(distfunc(repmat(locs(cchan, :), size(stwcLoc, 1), 1), stwcLoc));
%         PlotInteractions(repmat(locs(cchan, :)+[5 0 0], size(stwcLoc, 1), 1), stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), false(size(stwcLoc, 1)));
    end
end

maximize
SaveFig(OUTPUT_DIR, 'STWC_and_bPLV', 'png', '-r600');

%% look at the distances
load america

figure
bar(1, nanmean(stwcDist), 'edgecolor', 'k', 'facecolor', cm(1,:));
hold on;
bar(2,  nanmean(bplvDist), 'edgecolor', 'k', 'facecolor', cm(end, :));


ax = errorbar([nanmean(stwcDist) nanmean(bplvDist)], [nansem(stwcDist, 2) nansem(bplvDist, 2)]);
set(ax, 'linestyle', 'none');
set(ax, 'color', 'k');

set(gca,'xtick', [1 2])
set(gca,'xticklabel', {'STWC', 'bPLV'});
ylabel('Distance from CTL (mm)', 'fontsize', 14);
set(gca,'fontsize', 12);
title('Spatial comparison of interaction measures', 'fontsize', 14);

[h, p] = ttest2(stwcDist(~isnan(stwcDist)), bplvDist(~isnan(bplvDist)));
sigstar({{1, 2}}, p);

SaveFig(OUTPUT_DIR, 'STWC_and_bPLV_dist', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'STWC_and_bPLV_dist', 'png', '-r600');

%% do the same for hand MI only
bplv_save = bplvtrodes;
resultA_save = resultA;

hand = [6 7 8 9 10];

temp = zeros(size(bplvtrodes));
temp(hand, :) = bplvtrodes(hand, :);
bplvtrodes = temp;

resultA(~ismember(resultA(:,1), hand), :) = [];

%% plot all significant interactions on a single brain - hand
figure
PlotCortex('tail', 'r', [], .7); hold on;

bplvDist = NaN*ones(size(SIDS));
stwcDist = NaN*ones(size(SIDS));
distfunc = @(x,y) sqrt(sum((x-y).^2, 2));
   
for sIdx = 1:length(SIDS)
    subjid = SIDS{sIdx};
    load(fullfile(META_DIR, [subjid '_epochs.mat']), 'cchan', 'montage');

    locs = projectToHemisphere(trodeLocsFromMontage(subjid, montage, true), 'r');
    
    % ctl trode
    bPLVFrom = bplvtrodes(sIdx, 1);
    bPLVTo   = bplvtrodes(sIdx, 2);
    
    if (~isempty(find(resultA(:, 1)==sIdx)) || bPLVFrom ~=0)
        PlotDotsDirect('tail', locs(cchan, :)+[5 0 0], 0, 'r', [-1 1], 20, 'america', [], false, true);
    end
        
    if bPLVFrom ~= 0 % we have a bPLV interaction
        if (bPLVFrom ~= cchan && bPLVTo ~= cchan)
            warning('bPLV from/to channel does not equal the control channel fo %s', subjid);
        end
        
        bPLVFromLoc = locs(bPLVFrom, :);
        bPLVToLoc   = locs(bPLVTo,   :);
        
        % bplv trode
        PlotDotsDirect('tail', bPLVToLoc+[5 0 0], 1, 'r', [-1 1], 10, 'america', [], false, true);        
%         PlotInteractions(bPLVFromLoc+[5 0 0], bPLVToLoc+[5 0 0], 1);
        
        % save these for later
        bplvDist(sIdx) = distfunc(bPLVFromLoc, bPLVToLoc);        
    end     
    
    stwcLoc = projectToHemisphere(resultA(resultA(:, 1) == sIdx, 3:5), 'r');

    if (~isempty(stwcLoc))
        % stwc trode
        PlotDotsDirect('tail', stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), -1*ones(1, size(stwcLoc, 1)), 'r', [-1 1], 10, 'america', [], false, true);
        stwcDist(sIdx) = median(distfunc(repmat(locs(cchan, :), size(stwcLoc, 1), 1), stwcLoc));
%         PlotInteractions(repmat(locs(cchan, :)+[5 0 0], size(stwcLoc, 1), 1), stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), false(size(stwcLoc, 1)));
    end
end

maximize
SaveFig(OUTPUT_DIR, 'STWC_and_bPLV_hand', 'png', '-r600');


%% now do tongue MI

bplvtrodes = bplv_save;
resultA = resultA_save;

tongue = [1 2 3 4 5 11];

temp = zeros(size(bplvtrodes));
temp(tongue, :) = bplvtrodes(tongue, :);
bplvtrodes = temp;

resultA(~ismember(resultA(:,1), tongue), :) = [];

%% plot all significant interactions on a single brain - tongue
figure
PlotCortex('tail', 'r', [], .7); hold on;

bplvDist = NaN*ones(size(SIDS));
stwcDist = NaN*ones(size(SIDS));
distfunc = @(x,y) sqrt(sum((x-y).^2, 2));
   
for sIdx = 1:length(SIDS)
    subjid = SIDS{sIdx};
    load(fullfile(META_DIR, [subjid '_epochs.mat']), 'cchan', 'montage');

    locs = projectToHemisphere(trodeLocsFromMontage(subjid, montage, true), 'r');
    
    % ctl trode
    bPLVFrom = bplvtrodes(sIdx, 1);
    bPLVTo   = bplvtrodes(sIdx, 2);
    
    if (~isempty(find(resultA(:, 1)==sIdx)) || bPLVFrom ~=0)
        PlotDotsDirect('tail', locs(cchan, :)+[5 0 0], 0, 'r', [-1 1], 20, 'america', [], false, true);
    end
        
    if bPLVFrom ~= 0 % we have a bPLV interaction
        if (bPLVFrom ~= cchan && bPLVTo ~= cchan)
            warning('bPLV from/to channel does not equal the control channel fo %s', subjid);
        end
        
        bPLVFromLoc = locs(bPLVFrom, :);
        bPLVToLoc   = locs(bPLVTo,   :);
        
        % bplv trode
        PlotDotsDirect('tail', bPLVToLoc+[5 0 0], 1, 'r', [-1 1], 10, 'america', [], false, true);        
%         PlotInteractions(bPLVFromLoc+[5 0 0], bPLVToLoc+[5 0 0], 1);
        
        % save these for later
        bplvDist(sIdx) = distfunc(bPLVFromLoc, bPLVToLoc);        
    end     
    
    stwcLoc = projectToHemisphere(resultA(resultA(:, 1) == sIdx, 3:5), 'r');

    if (~isempty(stwcLoc))
        % stwc trode
        PlotDotsDirect('tail', stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), -1*ones(1, size(stwcLoc, 1)), 'r', [-1 1], 10, 'america', [], false, true);
        stwcDist(sIdx) = median(distfunc(repmat(locs(cchan, :), size(stwcLoc, 1), 1), stwcLoc));
%         PlotInteractions(repmat(locs(cchan, :)+[5 0 0], size(stwcLoc, 1), 1), stwcLoc+repmat([5 0 0], size(stwcLoc, 1), 1), false(size(stwcLoc, 1)));
    end
end

maximize
SaveFig(OUTPUT_DIR, 'STWC_and_bPLV_tongue', 'png', '-r600');

%% plot all significant interactions on a single brain - bplv
figure
PlotCortex('tail', 'r', [], .7); hold on;

bplvDist = NaN*ones(size(SIDS));
distfunc = @(x,y) sqrt(sum((x-y).^2, 2));
   
for sIdx = 1:length(SIDS)
    fprintf('%d\n', sIdx);
    
    subjid = SIDS{sIdx};
    load(fullfile(META_DIR, [subjid '_epochs.mat']), 'cchan', 'montage');

    locs = projectToHemisphere(trodeLocsFromMontage(subjid, montage, true), 'r');
    
    % ctl trode
    bPLVFrom = bplvtrodes(sIdx, 1);
    bPLVTo   = bplvtrodes(sIdx, 2);
    
    if (bPLVFrom ~=0)
        PlotDotsDirect('tail', locs(cchan, :)+[5 0 0], 0, 'r', [-1 1], 20, 'america', [], false, true);
    end
        
    if bPLVFrom ~= 0 % we have a bPLV interaction
        if (bPLVFrom ~= cchan && bPLVTo ~= cchan)
            warning('bPLV from/to channel does not equal the control channel fo %s', subjid);
        end
        
        bPLVFromLoc = locs(bPLVFrom, :);
        bPLVToLoc   = locs(bPLVTo,   :);
        
        % bplv trode
        ax = line([bPLVFromLoc(1) bPLVToLoc(1)]+[5 5], [bPLVFromLoc(2) bPLVToLoc(2)], [bPLVFromLoc(3) bPLVToLoc(3)]);
        set(ax,'color', 'k');
        set(ax,'linew', 2);
        
        PlotDotsDirect('tail', bPLVToLoc+[5 0 0], 1, 'r', [-1 1], 10, 'america', [], false, true);        
%         PlotInteractions(bPLVFromLoc+[5 0 0], bPLVToLoc+[5 0 0], 1);
        
    end         
end

maximize
SaveFig(OUTPUT_DIR, 'bPLV_only', 'png', '-r600');

