%% this script selects and shows interesting electrodes
% subjid = 'fc9643';
subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';
[~, odir] = filesForSubjid(subjid);

%% load data
% warning ('not loading new data\n');
load(fullfile(odir, [subjid '_epochs_clean.mat']), 'tgts', 'ress', 'Montage', 'bads', 'itiDur', 'preDur', 'fs', 'fbDur', 'postDur');
t  = (-itiDur-preDur):1/fs:(fbDur+postDur);

load(fullfile(odir, [subjid '_results']));




%% analyze each channel

% these were the parameters that I used for the BCI conference abstract
p_targ = 0.01;
tlim = 0.150; % in sec
% end

for chan = 1:max(cumsum(Montage.Montage))
    if (~ismember(chan, bads))
        fprintf('working on channel %d\n', chan);
        
        % load results from monte-carlo randomization
        load(fullfile(odir, 'stats', [num2str(chan) '.mat']));        
                
        [tvals_hg, clusters_hg] = findClusterStats(h_hg(chan, :), stats_hg.tstat(chan, :));
        [tvals_beta, clusters_beta] = findClusterStats(h_beta(chan, :), stats_beta.tstat(chan, :));

        % determine significant clusters from original statistical test
        off_hg = floor(size(alltvals_hg, 2)*(p_targ/2));
        off_beta = floor(size(alltvals_beta, 2)*(p_targ/2));
        
        sortedtvals_hg = sort(alltvals_hg);
        sortedtvals_beta = sort(alltvals_beta);

        if (off_hg > 0)
            lb_hg = sortedtvals_hg(off_hg);
            ub_hg = sortedtvals_hg(end-off_hg);
        else
            lb_hg = -Inf;
            ub_hg = Inf;
        end
        
        if (off_beta > 0)
            lb_beta = sortedtvals_beta(off_beta);
            ub_beta = sortedtvals_beta(end-off_beta);
        else
            lb_beta = -Inf;
            ub_beta = Inf;
        end

        keepers_hg = tvals_hg < lb_hg | tvals_hg > ub_hg;
        keepers_beta = tvals_beta < lb_beta | tvals_beta > ub_beta;

        cClusters_hg = clusters_hg(keepers_hg);
%         cClusters_beta = clusters_beta(keepers_beta);
        cClusters_beta = [];
        cTvals_hg = tvals_hg(keepers_hg);
        cTvals_beta = tvals_beta(keepers_beta);

        mask_hg = zeros(size(t));
        mask_beta = zeros(size(t));

        for c = 1:length(cClusters_hg)
            cc = cClusters_hg{c};

            for d = 1:size(cc,2)
                mask_hg(cc(1,d), cc(2,d)) = 1;
            end
        end

%         for c = 1:length(cClusters_beta)
%             cc = cClusters_beta{c};
% 
%             for d = 1:size(cc,2)
%                 mask_beta(cc(1,d), cc(2,d)) = 1;
%             end
%         end
        
        if (sum(mask_hg) > tlim*fs || sum(mask_beta) > tlim*fs)
            fprintf('significant clusters found (%d): %d\n', chan, length(cClusters_hg)+length(cClusters_beta));

            smhit_hg = GaussianSmooth(hitMean_hg(chan, :), 100);
            smmiss_hg = GaussianSmooth(missMean_hg(chan, :), 100);
            
            smhit_beta = hitMean_beta(chan, :);
            smmiss_beta = missMean_beta(chan, :);
            
            figure;
            
%             subplot(211);
            
            plot(t, smhit_hg, 'r'); 
            hold on;
            plot(t, smmiss_hg, 'b'); 
  
            legend('hit', 'miss', 'Location', 'Southwest');
            
            for c = 1:length(cClusters_hg)
                cc = cClusters_hg{c};
                
                highlight(gca, [t(min(cc(2,:))) t(max(cc(2,:)))], ylim, [0.2 0.8 0.2]);
                plot(t(cc(2,:)), smhit_hg(cc(2,:)), 'r', 'LineWidth', 2);
                plot(t(cc(2,:)), smmiss_hg(cc(2,:)), 'b', 'LineWidth', 2);                
            end

            ylims = ylim;
            plot([-preDur -preDur], ylims, 'k--');
            plot([0       0      ], ylims, 'k--');
            plot([fbDur   fbDur  ], ylims, 'k--');

            xlabel('Time (s)', 'FontSize', 15);
            ylabel('Feature power', 'FontSize', 15);
            title('HG response in \color{red}{hit} vs \color{blue}{miss} \color{black}{trials}', 'FontSize', 15);
                        
%             subplot(212);
%             
%             plot(t, smhit_beta, 'r'); 
%             hold on;
%             plot(t, smmiss_beta, 'b'); 
%             
%             for c = 1:length(cClusters_beta)
%                 cc = cClusters_beta{c};
%                 
%                 highlight(gca, [t(min(cc(2,:))) t(max(cc(2,:)))], ylim, [0.2 0.8 0.2]);
%                 plot(t(cc(2,:)), smhit_beta(cc(2,:)), 'r', 'LineWidth', 2);
%                 plot(t(cc(2,:)), smmiss_beta(cc(2,:)), 'b', 'LineWidth', 2);                                
%             end
%             plot(t(mask_beta==1), smhit_beta(mask_beta==1), 'r', 'LineWidth', 2);
%             plot(t(mask_beta==1), smmiss_beta(mask_beta==1), 'b', 'LineWidth', 2);
% 
%             ylims = ylim;
%             plot([-preDur -preDur], ylims, 'k--');
%             plot([0       0      ], ylims, 'k--');
%             plot([fbDur   fbDur  ], ylims, 'k--');
%             
%             xlabel('time (s)');
%             ylabel('feature power');
%             title('significant beta differences in \color{red}{hit} vs \color{blue}{miss} \color{black}{trials}');
            
%             maximize;
%             mtit(trodeNameFromMontage(chan, Montage), 'xoff', 0, 'yoff', 0.025);
            
            SaveFig(fullfile(odir, 'figs'), ['sig_' strrep(strrep(trodeNameFromMontage(chan, Montage), '(', ''), ')', '')], 'eps');
            close;
            
            if (~isempty(cClusters_hg))
                clusterChans_hg(chan) = 1;
                allClusters_hg{chan} = cClusters_hg;
                masks_hg{chan} = mask_hg;
                allRsas_hg{chan} = rsas_hg(chan, :);
            else
                clusterChans_hg(chan) = 0;
                allClusters_hg{chan} = {};
                masks_hg{chan} = {};
                allRsas_hg{chan} = {};
            end

            if (~isempty(cClusters_beta))
                clusterChans_beta(chan) = 1;
                allClusters_beta{chan} = cClusters_beta;
                masks_beta{chan} = mask_beta;
                allRsas_beta{chan} = rsas_beta(chan, :);
            else
                clusterChans_beta(chan) = 0;
                allClusters_beta{chan} = {};
                masks_beta{chan} = {};
                allRsas_beta{chan} = {};
            end            
        else
%             fprintf('no clusters found\n');
            clusterChans_hg(chan) = 0;
            allClusters_hg{chan} = {};
            masks_hg{chan} = {};
            allRsas_hg{chan} = {};

            clusterChans_beta(chan) = 0;
            allClusters_beta{chan} = {};
            masks_beta{chan} = {};
            allRsas_beta{chan} = {};            
        end
    else
        clusterChans_hg(chan) = 0;
        allClusters_hg{chan} = {};
        masks_hg{chan} = {};
        allRsas_hg{chan} = {};

        clusterChans_beta(chan) = 0;
        allClusters_beta{chan} = {};
        masks_beta{chan} = {};
        allRsas_beta{chan} = {};                    
    end
end

save(fullfile(odir, 'significant_clusters.mat'), 'clusterChans*', 'allClusters*', 'masks*', 'allRsas*', 'p_targ');