function newFeatures = extractFeaturesBasedOnTValues(features, labels, MAX_FEATS, MIN_P)
    DBG = 0;
    
    % these next two lines are circuitous, I know, but they do a good job
    % of guaranteeing that the frequency arrangement corresponds correctly
    % to the rearranged means
    freqTypes = reshape(repmat((1:size(features,3))', [1 size(features,1) size(features,2)]), [size(features, 1)*size(features,3) size(features,2)]);
    freqTypes = freqTypes(:,1);
    
    % rearrange the means
    means = reshape(shiftdim(features, 2), [size(features, 1)*size(features,3) size(features,2)]);
    
    % figure out which ones were meaningful
    [h, p, ~, t] = ttest2(means(:, labels), means(:, ~labels), 'dim', 2);
    t = t.tstat;    
        
    [sortp, order] = sort(p);
    sortabst = abs(t(order));
    sortTypes = freqTypes(order);
    
    % determine which ones are kept
    nKeepers = min(MAX_FEATS, find(sortp > MIN_P, 1));
    newFeatures = means(order(1:nKeepers),:);
    
    if (DBG)
        % visualize the results    
        fcolors = 'rgbcm';
        uniqueFreqs = unique(freqTypes);
        for fIdx = 1:length(uniqueFreqs)    
            idxs = find(sortTypes == uniqueFreqs(fIdx));
            bar(idxs, sortabst(idxs), 'facecolor', fcolors(fIdx));
            hold on;
        end

        vline(MAX_FEATS+0.5, 'k:');
        hline(sortabst(find(sortp > MIN_P, 1)), 'k:');

        xlim([-1 50]);

        xlabel('feature number');
        ylabel('abs (t)');
        legend(BAND_NAMES);
    end
end