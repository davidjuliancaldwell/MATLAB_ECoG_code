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
subjid = '4568f4';
[~, odir] = filesForSubjid(subjid);

% %% now, we need to figure out which trials will be partitioned off in to
% % each fold of the validation process.
% load(fullfile(subjid, [subjid '_decomp.mat']), 'tgts', 'ress');
% 
% numTrials = length(tgts);
% numFolds = 5;
% 
% randos = randperm(numTrials);
% trialIdxs = cell(numFolds, 1);
% 
% step = ceil(numTrials/numFolds);
% 
% for c = 1:numFolds
%     start = (c-1)*step + 1;
%     stop = min(c*step, numTrials);
%    
%     bools = ones(numTrials, 1);
%     bools(start:stop) = 0;
%     
%     trialIdxs{c} = randos(bools==1);
% end

%% now, working through each chanel, load in the decomposed channel data,
% perform the boostrap significance testing.  
bootrep = 50;
% pixelp = 0.05;

TouchDir(fullfile(odir, 'stats'));
load(fullfile(odir, [subjid '_decomp.mat']), 'bads', 'tgts', 'ress', 'Montage');



for chan = 1:max(cumsum(Montage.Montage))
    if (~ismember(chan, bads))
        fprintf('working on channel %d\n', chan);
        
        fprintf('loading... ');
        load(fullfile(odir, 'chan', sprintf('%d.mat', chan)), 'decompAll');
        fprintf('done\n');
        dca = abs(decompAll);

        alltvals = [];
        allhits = [];

        h = waitbar(0, sprintf('working on channel %d', chan));
        
        diffs = zeros(size(dca,1),size(dca,2),bootrep);
        
        for c = 1:bootrep
            if (mod(c, ceil(bootrep/10))==0)
                waitbar(c/bootrep, h);
            end
            
            m1 = mean(dca(:,:,hits),3);
            s1 = squeeze(m1);
            m2 = mean(dca(:,:,~hits),3);
            s2 = squeeze(m2);
            hits = buildRandomHitList(sum(ress==tgts), length(tgts));
            diffs(:,:,c) = s1-s2;

%             [h2,~,~,stats2] = ttest2unsafe(squeeze(dca(:,:,hits)), squeeze(dca(:,:,~hits)), pixelp, 'both', 'unequal', 3);
% 
%             tvals2 = findClusterStats(h2, stats2.tstat);

%             alltvals = cat(2,alltvals, tvals2);
            allhits = cat(2,allhits, hits);
        end
        
        close (h);
        
        fprintf('saving... ');
        save(fullfile(odir, 'stats', sprintf('%d.mat', chan)), 'alltvals', 'bootrep', 'pixelp', 'allhits');
        fprintf('done\n');
    end
end

