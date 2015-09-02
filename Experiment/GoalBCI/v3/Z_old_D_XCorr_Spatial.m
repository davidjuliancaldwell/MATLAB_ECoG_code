%% define constants
addpath ./functions
Z_Constants;

%%

allpeaks = [];
alllags = [];
alllocs = [];
allsubs = [];

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-xcorr-results.mat', subjid)), '*Corr', '*Distro', 'lags', 'fs', 'cchan', 'hemi', 'montage', 'bad_channels');

    eCorr(isnan(vCorr)) = 0;
    
    % let's look at errors only
    
    % first, threshold the correlation values based on significance
    highcrit = prctile(eDistro(:,1), 97.5);
    lowcrit = prctile(eDistro(:,2), 2.5);
    
    muCx = squeeze(mean(eCorr, 2));
    muCx = muCx .* double(muCx >= highcrit) + muCx .* double(muCx <= lowcrit);
    
    % now find the peaks and lags
    [cPeaks, cLags] = max(muCx);
    isreal = cPeaks >= highcrit;
    
%     % temp
% %     [~, maxpeak] = max(cPeaks); % hardcoded
%     maxpeak = cchan;
%     
%     load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)),'data', 'diffs', 'paths', 't', 'postDur');
%     mdata = data(maxpeak,:);
%     
% %     ares = zeros(121, 1);
%     ares = [];
%     
%     for e = 1:length(mdata)
% %         error = abs(diffs{e});
%         error = [0; diff(paths{e})];
%         brain = mdata{e};
%         
%         startIdx = find(t > 0, 1, 'first')+2;
%         endIdx = length(error)-postDur*fs;
% 
%         errord = error(startIdx:endIdx)-mean(error(startIdx:endIdx));
%         braind = brain(startIdx:endIdx)-mean(brain(startIdx:endIdx));
%         
%         ares = cat(1, ares, [error((startIdx:endIdx)+lags(cLags(maxpeak))),brain(startIdx:endIdx)]);
% % %         hold on;
% %         res = xcorr(errord, braind, 60, 'coeff');
% %         ares = ares + res;
% %         plot(res);
% %         hold on;        
%     end
% %     plot(ares/length(mdata), 'r', 'linew', 3);
% % %     hold off;
% 
%     [foo, C] = hist3(ares,[25,25]);
%     
%     fo2 = bsxfun(@rdivide, foo, sum(foo, 2));
%     imagesc(C{2}, C{1}, fo2);
% 
% %     imagesc(muCx);
% %     set(gca,'clim', [-max(abs(muCx(:))) max(abs(muCx(:)))]);
% %     load america
% %     colormap(cm);
%     
%     % / temp
    
    cLags = lags(cLags)/fs;
    
    if (any(isreal))
        % first save the ones we care about
        mlocs = trodeLocsFromMontage(subjid, montage, true);
        
        allpeaks = cat(2, allpeaks, cPeaks(isreal));
        alllags  = cat(2, alllags,  cLags(isreal));
        alllocs  = cat(1, alllocs, mlocs(isreal, :));
        allsubs  = cat(2, allsubs, c*ones(1, sum(isreal)));
%         % second, do individual plots
%         figure
%         w = cLags;
%         w(~isreal) = NaN;    
%         PlotDots(subjid, montage.MontageTokenized, w, hemi, [-max(abs(w)) max(abs(w))], 20, 'recon_colormap');
%         plot3(montage.MontageTrodes(cchan,1), montage.MontageTrodes(cchan,2), montage.MontageTrodes(cchan,3), 'ko', 'markersize', 20, 'linew', 3);
% 
%         load('recon_colormap');
%         colormap(cm);
%         colorbarLabel(colorbar, 'cross-correlation lag (sec)');
%         title(subjid)
    end        
end

%%
figure
maximize
alllocs = projectToHemisphere(alllocs, 'r');
subplot(121);
PlotDotsDirectWithCustomMarkers('tail', alllocs, allpeaks, 'r', [-max(abs(allpeaks)) max(abs(allpeaks))], 10, allsubs, 'america', [], false, false);
load('america');
colormap(cm);
colorbarLabel(colorbar, 'x-corr magnitude');
title('maximal x-corr peak');

subplot(122);
PlotDotsDirectWithCustomMarkers('tail', alllocs, alllags, 'r', [-max(abs(alllags)) max(abs(alllags))], 10, allsubs, 'america', [], false, false);
load('america');
colormap(cm);
colorbarLabel(colorbar, 'x-corr lag (sec)');
title('corresponding lag');

SaveFig(OUTPUT_DIR, 'all-xcorr', 'png', '-r600');

%% just to make my life easy, let's build a legend figure
possibleMarkers = 'osd^v<>ph';
anysub = 1:length(SIDS);

figure

for c = 1:length(anysub)
    plot(1, max(anysub)-anysub(c), possibleMarkers(anysub(c)), 'color', 'k', 'markersize', 15, 'linew', 2);
    text(1.1, max(anysub)-anysub(c), SUBCODES{c}, 'fontsize', 20);
    hold on;
end

ylim(ylim+[-1 1])

SaveFig(OUTPUT_DIR, 'all-xcorr-leg', 'png', '-r300');

    



