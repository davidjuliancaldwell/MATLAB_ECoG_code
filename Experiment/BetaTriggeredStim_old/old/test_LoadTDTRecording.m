% % %% setup
% % subjid = '8ad65c';
% % experiment = 'BetaTriggeredStim';
% % sblock = 66;
% % eblock = 68;
% % 
% % fs = 12000;
% % 
% % %% get the data
% % [ssig, ~] = loadTDTRecording(subjid, experiment, sblock);
% % [esig, ~] = loadTDTRecording(subjid, experiment, eblock);
% % 
% % %% average reference
% % ssig = ssig.data(:,1:48);
% % esig = esig.data(:,1:48);
% 
% ssig = double(ssig);
% esig = double(esig);
% 
% rssig = ssig - repmat(mean(ssig, 2), 1, size(ssig, 2));
% resig = esig - repmat(mean(esig, 2), 1, size(esig, 2));
% 
rssig(126550, :) = rssig(12654, :);
resig(372511, :) = resig(372510, :);
resig(612697, :) = resig(612696, :);
resig(1634531, :) = resig(1634530, :);
% 
% 
% % downsample, just kidding
% pre = rssig; %resample(rssig, 1, 12);
% post = resig; %resample(resig, 1, 12);
% fs = 12000;

pre = resample(rssig, 1, 4);
post = resample(resig, 1, 4);
fs = 3000;

% 
% %% divide in to epochs
prestarts = 1:(30*fs):length(pre);
prestarts(end) = [];

poststarts = 1:(30*fs):length(post);
poststarts(end) = [];

pre_e = getEpochSignal(pre, prestarts, prestarts+30*fs);
post_e = getEpochSignal(post, poststarts, poststarts+30*fs);
% 
%% SPECTRAL CHANGES

% % chans = sort(unique([randi(48, [12, 1]); [8 31 32 1]']));
% chans = sort([8 31 32 1]);
% dim = ceil(sqrt(length(chans)));
% 
% figure
% for c = 1:length(chans)
%     subplot(dim,dim,c);
%     
%     [~, hz, X_mu, X_sem] = spectralStats(squeeze(pre_e(:,chans(c),:)), fs);
%     legendOff(plot(hz, X_mu+X_sem)); hold on;
%     legendOff(plot(hz, X_mu-X_sem));
%     plot(hz, X_mu, 'linew', 2);
%     
%     [~, hz, X_mu, X_sem] = spectralStats(squeeze(post_e(:,chans(c),:)), fs);
%     legendOff(plot(hz, X_mu+X_sem,'r'));
%     legendOff(plot(hz, X_mu-X_sem,'r'));
%     plot(hz, X_mu, 'r', 'linew', 2);
%     
%     xlim([0 200]);
%     xlabel('freq (hz)');
%     ylabel('power (log(uV))');
%     
%     legend('pre','post');
%     title(num2str(chans(c)));
% end
% 
% maximize;
% saveas(gcf, 'spectra.png');
% 
% %
% 
% pairs = nchoosek(chans, 2);
% dim = ceil(sqrt(length(pairs)));
% 
% figure;
% for pairIdx = 1:size(pairs, 1)
%     subplot(2, 3, pairIdx);
%     pair = pairs(pairIdx, :);
%     
%     [~, hz, C_mu, C_sem] = cohStats(squeeze(pre_e(:,pair(1),:)), squeeze(pre_e(:,pair(2),:)), fs);
%     legendOff(plot(hz, C_mu+C_sem)); hold on;
%     legendOff(plot(hz, C_mu-C_sem));
%     plot(hz, C_mu, 'linew', 2);
%     
%     [~, hz, C_mu, C_sem] = cohStats(squeeze(post_e(:,pair(1),:)), squeeze(post_e(:,pair(2),:)), fs);
%     legendOff(plot(hz, C_mu+C_sem,'r'));
%     legendOff(plot(hz, C_mu-C_sem,'r'));
%     plot(hz, C_mu, 'r', 'linew', 2);
%     
%     xlim([0 200]);
%     ylim([0 0.1])
%     xlabel('freq (hz)');
%     ylabel('coherence');
%     
%     legend('pre','post');
%     title(sprintf('%d <-> %d', pair(1), pair(2)));
% end
% 
% maximize;
% saveas(gcf, 'coherence.png');


%%

pairs = nchoosek(chans, 2);
dim = ceil(sqrt(length(pairs)));

fw = 1:1:200;

figure;
for pairIdx = 1:size(pairs, 1)
    subplot(2, 3, pairIdx);
    pair = pairs(pairIdx, :);
    
    [~, hz, P_mu, P_sem] = mplv(squeeze(pre_e(:,pair(1),:)), squeeze(pre_e(:,pair(2),:)), fs, fw);
    legendOff(plot(hz, P_mu+P_sem)); hold on;
    legendOff(plot(hz, P_mu-P_sem));
    plot(hz, P_mu, 'linew', 2);
    
    [~, hz, P_mu, P_sem] = mplv(squeeze(post_e(:,pair(1),:)), squeeze(post_e(:,pair(2),:)), fs, fw);
    legendOff(plot(hz, P_mu+P_sem, 'r')); hold on;
    legendOff(plot(hz, P_mu-P_sem, 'r'));
    plot(hz, P_mu, 'r', 'linew', 2);
    
    xlim([0 200]);
    ylim([0 0.5])
    xlabel('freq (hz)');
    ylabel('plv');
    
    legend('pre','post');
    title(sprintf('%d <-> %d', pair(1), pair(2)));
end

maximize;
saveas(gcf, 'plv.png');

% %%
% Cxx = corr(rssig(:,:));
% subplot(211);
% imagesc(Cxx.^2);
% set(gca,'xtick',1:4);
% set(gca,'xticklabel', chans);
% set(gca,'ytick',1:4);
% set(gca,'yticklabel', chans);
% 
% title('preCorr');
% colorbar;
% 
% subplot(212);
% Cxx = corr(resig(:,:));
% imagesc(Cxx.^2);
% set(gca,'xtick',1:4);
% set(gca,'xticklabel', chans);
% set(gca,'ytick',1:4);
% set(gca,'yticklabel', chans);
% title('postCorr');
% colorbar;
% 
% saveas('corrs.png');
% 
