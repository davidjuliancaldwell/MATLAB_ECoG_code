subjid = '8ad65c';
experiment = 'BetaTriggeredStim';
sblock = 66;
eblock = 68;

[ssig, ~] = loadTDTRecording(subjid, experiment, sblock);
[esig, ~] = loadTDTRecording(subjid, experiment, eblock);

chans = [8 31 32 1];

ssig = ssig.data(:,1:48);
esig = esig.data(:,1:48);

rssig = ssig - repmat(mean(ssig, 2), 1, size(ssig, 2));
resig = esig - repmat(mean(esig, 2), 1, size(esig, 2));

rssig = rssig(:, chans);
resig = resig(:, chans);

fs = 12000;

%%
figure
for c = 1:length(chans)
    subplot(2,2,c);
    
    [X, hz] = pwelch(rssig(:,c), fs, fs/2, fs, fs);
    plot(hz, log(X));
    hold all;
    [X, hz] = pwelch(resig(:,c), fs, fs/2, fs, fs);
    plot(hz, log(X));
    xlim([0 200]);
    legend('pre','post');
    title(num2str(chans(c)));
end

saveas('spectra.png');

%%
Cxx = corr(rssig(:,:));
subplot(211);
imagesc(Cxx.^2);
set(gca,'xtick',1:4);
set(gca,'xticklabel', chans);
set(gca,'ytick',1:4);
set(gca,'yticklabel', chans);

title('preCorr');
colorbar;

subplot(212);
Cxx = corr(resig(:,:));
imagesc(Cxx.^2);
set(gca,'xtick',1:4);
set(gca,'xticklabel', chans);
set(gca,'ytick',1:4);
set(gca,'yticklabel', chans);
title('postCorr');
colorbar;

saveas('corrs.png');

