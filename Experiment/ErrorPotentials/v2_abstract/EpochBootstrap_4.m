%% EpochBootstrap
%
%
% This script is to build up the bootstrap databases for all statistical
% analyses.
%
% It builds six databases for a given channel. Each database only consists
% of a single vector of t-statistics from randomized clusters generated
% from a given subset of trials.  The database also includes a little bit
% of relevant information used in the analysis / randomization.

%% basic setup: provide the subjid you want to run for
% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';

[~, odir] = filesForSubjid(subjid);

%% now, working through each chanel, load in the decomposed channel data,
% perform the boostrap significance testing.  
bootrep = 1000;
samplep = 0.05;

TouchDir(fullfile(odir, 'stats'));
load(fullfile(odir, [subjid '_epochs_clean.mat']), 'bads', 'tgts', 'ress', 'Montage', 'epochs_beta', 'epochs_hg');

for chan = 1:max(cumsum(Montage.Montage))
    if (~ismember(chan, bads))
        fprintf('working on channel %d\n', chan);
        
        alltvals_hg = [];
        alltvals_beta = [];
        allhits = [];

        wait_handle = waitbar(0, sprintf('working on channel %d', chan));
        
        for c = 1:bootrep
            if (mod(c, ceil(bootrep/10))==0)
                waitbar(c/bootrep, wait_handle);
            end
            
            hits = buildRandomHitList(sum(ress==tgts), length(tgts));

            [h_hg,~,~,stats_hg] = ttest2unsafe(squeeze(epochs_hg(chan,hits,:)), squeeze(epochs_hg(chan,~hits,:)), samplep, 'both', 'unequal', 1);
            tvals_hg = findClusterStats(squeeze(h_hg), squeeze(stats_hg.tstat));
            alltvals_hg = cat(2,alltvals_hg, tvals_hg);
            
            [h_beta,~,~,stats_beta] = ttest2unsafe(squeeze(epochs_beta(chan,hits,:)), squeeze(epochs_beta(chan,~hits,:)), samplep, 'both', 'unequal', 1);
            tvals_beta = findClusterStats(squeeze(h_beta), squeeze(stats_beta.tstat));
            alltvals_beta = cat(2,alltvals_beta, tvals_beta);
            
            allhits = cat(2,allhits, hits);
        end
        
        close (wait_handle);
        
        save(fullfile(odir, 'stats', sprintf('%d.mat', chan)), 'alltvals_hg', 'alltvals_beta', 'bootrep', 'samplep', 'allhits'); 
    end  
end

