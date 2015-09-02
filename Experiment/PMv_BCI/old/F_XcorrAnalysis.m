%%
Z_Constants;

%% perform analyses
load(fullfile(META_DIR, 'areas.mat'));

peakSave = {};
lagSave = {};

for ctr = 1:length(SIDS)
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    load(fullfile(META_DIR, [sid '_epochs']));
    
    ups = tgts == 1;
    hits = tgts == ress;
    accs(ctr) = mean(hits);
    
    [~,~,~,Montage,cchan] = filesForSubjid(sid);
    
    trs = trodesOfInterest{ctr};
    trs(trs==cchan) = [];
    
    ctl = squeeze(epochs_hg(cchan, :, :));
    pmv = epochs_hg(trs, :, :);
    
    %% do the analysis
    peaks = zeros(size(pmv, 1), size(pmv, 2));
    lags  = zeros(size(pmv, 1), size(pmv, 2));
        
    L = 25;
    if (strcmp(sid, 'fc9643'));
%         ts = t > -preDur & t < (-preDur + 1);
        ts = t > 0 & t < 1;    
    else
        ts = t > 0 & t < 1;    
    end
    
    res = zeros(length(trs), size(ctl, 1), 2*L+1);
    
    fprintf('%d: ', size(pmv, 1));
    
    for pmvChan = 1:size(pmv, 1)
        fprintf('.');
        pmvc = squeeze(pmv(pmvChan, :, :));
        
        for epoch = 1:size(ctl, 1)
%             ce = ctl(epoch, ts);
            ce = GaussianSmooth(ctl(epoch, ts), 1);
            pe = GaussianSmooth(pmvc(epoch, ts), 1);
%             pe = pmvc(epoch, ts);
            [res(pmvChan, epoch, :), lags] = xcorr(ce-mean(ce), pe-mean(pe), L, 'coeff');
            
%             plot(lags, peaks); ylim([-.3 .3]);
%             title(sprintf('ishit = %d, isup = %d', hits(epoch), ups(epoch)));
%             x = 5;
%             res(pmvChan, epoch, :) = slidingCorr(ctl(epoch, :), pmvc(epoch, :), L, 1);
        end                
                
        types = hits + ups*2;
        [stypes, idx] = sort(types);

        subplot(211);
        imagesc(lags/fs, 1:length(types), squeeze(res(pmvChan,idx,:)))
        title(sprintf('%s - %s',sid, trodeNameFromMontage(trs(pmvChan), Montage)));
        set(gca, 'clim', [-.4 .4]);
        
        ax = hline(find(diff([0; stypes])), 'k');
        set(ax, 'linew', 2);
        subplot(212);
        prettyline(lags/fs, squeeze(res(pmvChan, :, :))', types);
        legend({'dn miss', 'up miss', 'dn hit', 'up hit'});        
        xlabel('time (s)');
        ylabel('cross-correlation coeff');
        title('<<< ctl leads | PMv leads >>>');
        
        SaveFig(OUTPUT_DIR, sprintf('%s_xcorr_%d', sid, trs(pmvChan)), 'png');
        
%         [lagSave{ctr}(pmvChan), peakSave{ctr}(pmvChan)] = getBestLag(squeeze(mean(res(pmvChan, ups & hits, :),2)), lags);
        
    end
    fprintf('\n');

    ux = squeeze(mean(res(:, ups, :), 2));
    peakSave{ctr} = max(ux');
    
    save(fullfile(META_DIR, sprintf('%s_corr.mat', sid)), 'L', 'res', 'ctl', 'pmvc');
    
%     %% do some plots
%     types = hits + ups*2;
%     
%     figure;
%     maximize;
%      
%     for pmvChan = 1:size(pmv, 1)
%         prettyline(t(1:(end-L)), squeeze(res(pmvChan, :, :))', types);
%         vline([-preDur 0 fbDur], 'k');
%         xlabel('time');
%         ylabel('sw-corr (|HG|)');
%         title(sprintf('%d (ctl) <=> %d (PMv)', cchan, trs(pmvChan)));
%         legend({'dn miss', 'up miss', 'dn hit', 'up hit'});
%         SaveFig(fullfile(OUTPUT_DIR, sid), sprintf('%d_swcorr', trs(pmvChan)), 'png');
%     end
end

%%
figure

x = [];
y = [];

for c = 1:length(SIDS)
%     x = cat(2, x, peakSave{c});
%     y = cat(2, y, repmat(accs(c), size(peakSave{c})));
    x(c) = median(peakSave{c});    
    y(c) = accs(c);
end

scatter(x, y);
lsline
[r, p] = corr(x',y')

legend('individuals', sprintf('r = %1.2f, p = %1.2f', r, p));

SaveFig(OUTPUT_DIR, 'xcorrpeak_vs_acc', 'png');
