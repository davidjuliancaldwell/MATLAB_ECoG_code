%% this script selects which electrodes are meaningful for future classification analyses

subjid = 'fc9643';
[~, odir] = filesForSubjid(subjid);

%% load data
load(fullfile(odir, [subjid '_decomp.mat']), 'tgts', 'ress', 'fw' , 't', 'Montage', 'bads');

%% analyze each channel

for chan = 1:max(cumsum(Montage.Montage))
    if (~ismember(chan, bads))
        % load in channel data
        fprintf('loading channel data: %d\n', chan);
        load(fullfile(odir, 'chan', [num2str(chan) '.mat']));
        dca = abs(decompAll);

        % perform t-test of hit vs missed trials
        fprintf('perfoming t-test...');
        tic
        [h,p,~,stats] = ttest2(squeeze(dca(:,:,ress==tgts)), squeeze(dca(:,:,ress~=tgts)), 0.05, 'both', 'unequal', 3);
        [tvals, clusters] = findClusterStats(h, stats.tstat);
        toc

        % calculate rsa values for hit vs missed trials
        fprintf('performing rsas...');
        tic
        rsas = zeros(size(p));
        for c = 1:length(fw)
            rsas(:,c) = signedSquaredXCorrValue(squeeze(dca(:,c,ress==tgts)), squeeze(dca(:,c,ress~=tgts)), 2);
        end
        toc

        % load results from monte-carlo randomization
        load(fullfile(odir, 'stats', [num2str(chan) '.mat']));

        % determine significant clusters from original statistical test
        p_targ = 0.0001;
        off = floor(size(alltvals, 2)*(p_targ/2));

        sortedTVals = sort(alltvals);

        lb = sortedTVals(off);
        ub = sortedTVals(end-off);

        keepers = tvals < lb | tvals > ub;

        cClusters = clusters(keepers);
        cTvals = tvals(keepers);

        mask = zeros(size(p));

        if (~isempty(cClusters))
            fprintf('significant clusters found: %d\n', length(cClusters));

            for c = 1:length(cClusters)
                cc = cClusters{c};

                for d = 1:size(cc,1)
                    mask(cc(d,1), cc(d,2)) = 1;
                end
            end

            figure;
            imagesc(t, fw, (rsas .* mask)');
            m = max(max(abs(rsas)));
            set_colormap_threshold(gca, [-0.01*m 0.01*m], [-m m], [1 1 1]); 
            % load('recon_colormap');
            % colormap(cm);
            % set(gca, 'CLim', [-m m]);
            colorbar;
            title(sprintf('R^2 of hits vs. misses: %s', trodeNameFromMontage(chan, Montage)));
            xlabel('time (s)');
            ylabel('frequency (Hz)');

            axis xy;    

            SaveFig(fullfile(odir, 'fig'), [num2str(chan) '.eps'], 'eps');

            close;
            
            clusterChans(chan) = 1;
            allClusters{chan} = cClusters;
            masks{chan} = mask;
            allRsas{chan} = rsas;
        else
            fprintf('no clusters found\n');
            clusterChans(chan) = 0;
            allClusters{chan} = {};
            masks{chan} = {};
            allRsas{chan} = {};
        end
    end
end

save(fullfile(odir, 'significant_clusters.mat'), 'clusterChans', 'allClusters', 'masks', 'allRsas', 'p_targ');