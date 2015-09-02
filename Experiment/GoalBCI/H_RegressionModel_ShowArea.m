%% define constants
addpath ./functions
Z_Constants;

DO_FORCE = false;
DO_GAUSS = true;
NADDS = 1;

%% This script is going to try to condense the results from the individual regression models down to something
% digestable and meaningful on an average subject basis.

% what are the questions we want to ask?
% is there significant representation of feature X?
% is there a spatial trend to the representation of that feature?
% does the representation of that feature come at a consistent lag across
% subjects?

% For velocity
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For error
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For interaction
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For direction
%  Thresholded Gaussian Plots of t-statistics 

%% collect the data
if (DO_FORCE)
	txts = {'velocity', 'error' 'interaction'};
% 	txts = {'paths', 'velocity', 'error', 'interaction', 'derror'};
%     txts = {'velocity', 'interaction', 'derror'};
%     txts = {'velocity', 'error', 'interaction'};
    
    weights = cell(length(txts) + NADDS, 1);
    locs =    cell(length(txts) + NADDS, 1);
    srcs =    cell(length(txts) + NADDS, 1);
    bas =     cell(length(txts) + NADDS, 1);
    hmats =   cell(length(txts) + NADDS, 1);
    lags =    cell(length(txts) + NADDS, 1);
    goods =   cell(length(txts) + NADDS, 1);
    
    for c = 1:length(SIDS)
        subjid = SIDS{c};
        subcode = SUBCODES{c};

        load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'cchan', 'hemi', 'montage', 'bad_channels');
        load(fullfile(META_DIR, ['regression ' subjid '.mat']), 'ts', 'ps', 'amaxlag', 'included');

        areas = brodmannAreaForMontage(subjid, montage)';        
        tlocs = trodeLocsFromMontage(subjid, montage, true);
        
        % count the total number of predictors included in all models for
        % this subject
        pthresh = 0.05 / sum(cellfun(@(x) sum(x), included));
        
        for d = 1:(length(txts) + NADDS)
            temp = toCol(cellfun(@(x) x(d),ts));
            tempp = toCol(cellfun(@(x) x(d),ps));

            if (c==3)
                temp(63:64) = [];
                tempp(63:64) = [];
            end
            
%             % most conservative, full bonf
%             good = tempp <= 0.05 / length(ps) * length(ps{1});

%             % intermediately conservative, bonf on all considered preds
%             good = tempp <= pthresh;
            
            % bonf on this predictor alone (n chans)
            [~, good] = bonf(tempp, 0.05);

            goods{d} = cat(1, goods{d}, good);
            weights{d} = cat(1, weights{d}, temp);
            locs{d} = cat(1, locs{d}, projectToHemisphere(tlocs,'r'));                
            srcs{d} = cat(1, srcs{d}, c*ones(length(good),1));
            hmats{d} = cat(1, hmats{d}, hmatValueForElectrodes(tlocs));
            bas{d} = cat(1, bas{d}, areas);
            
            if (d <= length(txts))
                lags{d} = cat(1, lags{d}, toCol(amaxlag{d}));
            else
                lags{d} = cat(1, lags{d}, zeros(length(good),1));
            end
        end               
    end        

    save(fullfile(META_DIR, 'regression_area_results.mat'), 'weights', 'locs', 'srcs', 'hmats', 'bas', 'txts', 'lags', 'goods');
else
    load(fullfile(META_DIR, 'regression_area_results.mat'), 'weights', 'locs', 'srcs', 'hmats', 'bas', 'txts', 'lags', 'goods');
end

% %%
% foo = bas{1};
% foo(foo==0) = NaN;
% 
% figure
% PlotDotsDirect('tail', locs{1}, foo, 'r', [0 max(foo)], 10, 'recon_colormap',foo,true);

%% we want to know who has coverage in what area, and who had an effect in what area.

for r = 1:4

    % this could be something much more complicated, but for now we'll just use
    % BAs
    areas = bas{r};

    % first, get rid of any electrodes that don't have an area
    bads = isnan(areas);
    areas(bads) = [];
    locs{r}(bads, :) = [];
    weights{r}(bads, :) = [];
    srcs{r}(bads) = [];
    goods{r}(bads) = [];
    srcs{r}(bads) = [];

    % now figure out coverage and activity counts for each area
    coverage = false(length(SIDS), length(unique(areas)));
    activity = false(length(SIDS), length(unique(areas)));

    uareas = unique(areas);

    for c = 1:length(SIDS)
        for d = 1:length(uareas)
            idxs = srcs{r}==c;
            if (any(areas(idxs) == uareas(d)))
                coverage(c, d) = true;

                hits = find(areas(idxs)==uareas(d));

                activity(c, d) = any(goods{r}(hits));
            end
        end
    end

    figure
%     bar([sum(activity); sum(coverage)]')
%     set(gca, 'xtick', 1:length(uareas))
%     set(gca, 'xticklabel', uareas)

    occ = sum(activity)./sum(coverage);
    occ(sum(activity) <= 1 & sum(coverage) > 1) = 0;
    
    PlotBrodmann(uareas, occ);
    load('recon_colormap');
    colormap(cm);
    view(90,0);
    axis equal
    axis off
    camlight
    set(gca, 'clim', [-1 1]);
    colorbarLabel('fractional occurrence');
    
    if (r <= length(txts))
        title(txts{r});
    else
        title('target location');
    end
end

return
%%

distThresh = 15; % mm

for d = 1:(length(txts) + NADDS)
    act = zeros(1, length(goods{d}));
    count = act;
    
    for idx = 1:length(goods{d})

        srcLoc = locs{d}(idx,:);

        ds = sqrt((locs{d}(:,1)-srcLoc(:,1)).^2 + (locs{d}(:,2)-srcLoc(:,2)).^2 + (locs{d}(:,3)-srcLoc(:,3)).^2);

        closes = find(ds <= distThresh);
        
        [subs,~,subsi] = unique(srcs{d}(closes));
        
        for sub = subs'
            if (any(goods{d}(closes(sub==subsi))))
                act(idx) = act(idx) + 1;
            end
        end
        
        count(idx) = length(unique(srcs{d}(closes)));        
    end
    
    if (d == 1)
        figure
        PlotDotsDirect('tail', locs{d}, count, 'r', [0 max(count)], 5, 'america', [], false);
        load('america');
        colormap(cm);
        colorbar;
        title('Coverage density');
        
%         SaveFig(OUTPUT_DIR, 'area representation', 'png', '-r300');
    end
  
    keeps = goods{d}' & act >= 2 & act./count >=.333;
    
%     keeps = act >= 2 & act./count >= 0.5;
%     keeps = goods{d}'&act>=2&act./count >= 0.5;
    
    figure
%     PlotDotsDirect('tail', locs{d}(keeps, :) + repmat([1 0 0], sum(keeps), 1), weights{d}(keeps), 'r', getCLims(weights{d}(keeps)), 10, 'america', srcs{d}(keeps), true);
    PlotDotsDirect('tail', locs{d}(keeps, :) + repmat([1 0 0], sum(keeps), 1), weights{d}(keeps), 'r', getCLims(weights{d}(keeps)), 10, 'america', srcs{d}(keeps), true);
    
%     PlotGaussDirect('tail', locs{d}(keeps, :), act(keeps)./count(keeps), 'r', [-3 3], 'america');
    load('america');
    colormap(cm);
    colorbarLabel('Frac. possible');
%     maximize;
    
    if (d <= length(txts))
        word = txts{d};
    else
        word = 'location';
    end
    
    title(word);
%     SaveFig(OUTPUT_DIR, ['area ' word], 'png', '-r300');
    
end


