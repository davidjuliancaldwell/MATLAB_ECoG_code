%% This script addresses the question of whether the HG power at the 
%% control electrode is bimodally distributed in the two target case,
%% the three target case, both, or neither.

% note that at this point we're not doing all of the fancy bad trial
% elimination that is being performed in the primary error potentials
% scripts

subjid = 'fc9643';
cChan = 33; % channel of interest
isNegCtl = true; % simply changes the names of the figures that are saved
overlapMus = false; % whether or not to display the trial histograms as separate
  % subplots or to display them overlapping on one.  Don't set to true
  % unless you want to look at a sloppy mess.

targetCounts = [2 3 5];
targetStrings = {'two_targets', 'three_targets', 'five_targets'};

%% collect data files

for c = 1:length(targetCounts)
    tgt = targetCounts(c);
    [odir, hemi, bads, ~, f] = ErrorPotentialsDataFiles(subjid, tgt);
    files.(targetStrings{c}) = f{:};
end

odir = ['d:\research\code\output\ErrorPotentials\' subjid];

% [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles('fc9643', 2);
% [odir, hemi, bads, ~, files3] = ErrorPotentialsDataFiles('fc9643', 3);

%% collect all of the epochs

for c = 1:length(targetCounts)
    fprintf('working on %d target files\n', c);
    
    tgt = targetCounts(c);
    stgt = targetStrings{c};
        
    hg_samps = cell(tgt, 1);
    hg_blocks = cell(tgt, 1);
    hg_means = cell(tgt, 1);

    for d = 1:length(files.(stgt))
        fprintf('-> working on file %d of %d\n', d, length(files.(stgt)));
        
        fname = files.(stgt){d};
        [sig, sta, par] = load_bcidat(fname);
        load(strrep(fname, '.dat', '_montage.mat'));
        
        sig = double(sig);
        Montage.BadChannels = union(Montage.BadChannels, [60 61 62 63 64]);
        sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
        
%         cChan = getControlChannel(subjid);
        
        hg = log(hilbAmp(sig(:, cChan), [70 200], par.SamplingRate.NumericValue).^2);
        
        for e = 1:tgt
            fprintf('-> -> analyzing target code %d of %d\n', e, tgt);
            
            hg_samps{e} = cat(1, hg_samps{e}, hg(sta.Feedback == 1 & sta.TargetCode == e));
            
            tempSig = hg(sta.Feedback == 1 & sta.TargetCode == e);
            tempSig = reshape(tempSig, length(tempSig)/par.SampleBlockSize.NumericValue, par.SampleBlockSize.NumericValue);
            tempSig = squeeze(mean(tempSig, 2));
            hg_blocks{e} = cat(1, hg_blocks{e}, tempSig);
            
            [starts, ends] = getEpochs(sta.Feedback == 1 & sta.TargetCode == e, 1, 1);
            tempSig = getEpochSignal(hg, starts, ends);
            
            hg_means{e} = cat(1, hg_means{e}, squeeze(mean(tempSig, 1)));
        end
    end
    
    results.(stgt).hg_samps = hg_samps;
    results.(stgt).hg_blocks = hg_blocks;
    results.(stgt).hg_means = hg_means;
end

%% display results

for c = 1:length(targetCounts)
    h_block = figure;
    h_mu = figure;
    
    tgt = targetCounts(c);
    stgt = targetStrings{c};
    
    mus = results.(stgt).hg_means;
    blocks = results.(stgt).hg_blocks;
    samps = results.(stgt).hg_samps;

    if (tgt == 2)
        [h, p] = ttest2(mus{1}, mus{2})
        [h, p] = ttest2(blocks{1}, blocks{2})
        [h, p] = ttest2(samps{1}, samps{2})
    end
    
    colors = 'rgbck';
    
    % for average responses per trial
    figure(h_mu);
    
    if (overlapMus == true)
        for d = 1:tgt
            hist(mus{d},25);
            hold on;
        end

        h = findobj(gca,'Type','patch');

        for d = 1:tgt
            set(h(d),'FaceColor',colors(d),'EdgeColor','w','facealpha',0.5)
        end

        title(sprintf('mean target activations - %s - %s', subjid, stgt));
        xlabel('log hg power');
        ylabel('trials');
    else
        mind = Inf;
        maxd = -Inf;
              
        for d = 1:tgt
            subplot(tgt, 1, d);
            hist(mus{d}, 25);
            h = findobj(gca,'Type','patch');
            set(h, 'FaceColor', colors(d));
            ax(d) = gca;
            ylabel('trials');
            
            mind = min(mind, min(xlim));
            maxd = max(maxd, max(xlim));
            legend(num2str(d));
        end
        mtit(sprintf('mean target activations - %s - %s', subjid, strrep(stgt, '_', ' ')));        
        xlabel('log hg power');
        
        for  d = 1:tgt
            set(ax(d), 'xlim', [mind maxd]);
        end
    end
    if (isNegCtl == true)
        SaveFig(odir, [stgt '_means_ctl'], 'eps');
    else
        SaveFig(odir, [stgt '_means'], 'eps');        
    end
    
    % for all individual blocks
    figure(h_block);
    
    for d = 1:tgt
        h = histfit(blocks{d},100);
        set(h(2), 'Color', colors(d));
        hold on;
    end
    
    h = findobj(gca,'Type','patch');
    
    for d = 1:tgt
        set(h(d),'FaceColor',colors(tgt+1-d),'EdgeColor','w','facealpha',0.5)
    end
    
    title(sprintf('block-based target activations - %s - %s', subjid, strrep(stgt,'_',' ')));
    xlabel('log hg power');
    ylabel('blocks');
    
    if (isNegCtl == true)
        SaveFig(odir, [stgt '_blocks_ctl'], 'eps');
    else
        SaveFig(odir, [stgt '_blocks'], 'eps');
    end        
end
