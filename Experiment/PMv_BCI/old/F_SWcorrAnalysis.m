%%
Z_Constants;

%% perform analyses
load(fullfile(META_DIR, 'areas.mat'));

peakSave = {};
lagSave = {};

for ctr = 7%1:length(SIDS)
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
    ctl_beta = squeeze(epochs_beta(cchan, :, :));
    
    pmv = epochs_hg(trs, :, :);
    pmv_beta = epochs_beta(trs, :, :);
    
    %% do the analysis
    peaks = zeros(size(pmv, 1), size(pmv, 2));
    lags  = zeros(size(pmv, 1), size(pmv, 2));
        
    L = 50;
    res = zeros(length(trs), size(ctl, 1), size(ctl, 2) - L);
    
    fprintf('%d: ', size(pmv, 1));
    
    plotting = true; % change to false in debug console
    
    for pmvChan = 1:size(pmv, 1)
        fprintf('.');
        pmvc = squeeze(pmv(pmvChan, :, :));
        
        for epoch = 1:size(ctl, 1)
            res(pmvChan, epoch, :) = slidingCorr(ctl(epoch, :), pmvc(epoch, :), L, 1);
            if (plotting)

                figure
                plot(squeeze(res(pmvChan, epoch, :)));
                hold all;
                plot(ctl_beta(epoch, :));
                plot(squeeze(pmv_beta(pmvChan, epoch, :)));     
                title(sprintf('isup = %d, ishit = %d', ups(epoch), hits(epoch)));
                close
            end
        end                
                
%         types = hits + ups*2;
%         [stypes, idx] = sort(types);
% 
%         subplot(211);
%         imagesc(lags/fs, 1:length(types), squeeze(res(pmvChan,idx,:)))
%         title(sprintf('%s - %s',sid, trodeNameFromMontage(trs(pmvChan), Montage)));
%         set(gca, 'clim', [-.4 .4]);
%         
%         ax = hline(find(diff([0; stypes])), 'k');
%         set(ax, 'linew', 2);
%         subplot(212);
%         prettyline(lags/fs, squeeze(res(pmvChan, :, :))', types);
%         legend({'dn miss', 'up miss', 'dn hit', 'up hit'});        
%         xlabel('time (s)');
%         ylabel('cross-correlation coeff');
%         title('<<< ctl leads | PMv leads >>>');
%         
%         SaveFig(OUTPUT_DIR, sprintf('%s_xcorr_%d', sid, trs(pmvChan)), 'png');
%         
% %         [lagSave{ctr}(pmvChan), peakSave{ctr}(pmvChan)] = getBestLag(squeeze(mean(res(pmvChan, ups & hits, :),2)), lags);
        
    end
    fprintf('\n');

%     ux = squeeze(mean(res(:, ups, :), 2));
%     peakSave{ctr} = max(ux');
%     
%     save(fullfile(META_DIR, sprintf('%s_corr.mat', sid)), 'L', 'res', 'ctl', 'pmvc');
    
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

