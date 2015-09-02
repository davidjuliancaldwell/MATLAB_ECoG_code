%%
figure, PlotCortex('9d10c8', 'l');
PlotElectrodes('9d10c8');

%% 

Z_Constants;

load d:\research\code\output\goalBCI\meta\S9-timeseries.mat
load d:\research\code\output\goalBCI\meta\S9-epochs.mat targets

runs = [33 48 80 97 114 121];

%

len = Inf;

for rec = 1:size(timeSeries, 2)
    len = min(length(timeSeries{1, rec}), len); 
end

%%
ts = nan(size(timeSeries, 1), size(timeSeries, 2), len);

t = (1:len)/tsfs - 3;
tx = 1:size(ts, 2);

rt = t < -2;

for rec = 1:size(timeSeries, 2)
%     mlen = length(timeSeries{1, rec});
    
    temp = [timeSeries{:, rec}]';
    ts(:, rec, :) = log(temp(:, 1:len).^2);
    mu = mean(ts(:, rec, rt),3);
    
    ts(:, rec, :) = ts(:, rec, :) - repmat(mu, [1, 1, size(ts, 3)]);
end

%%

ups = ismember(targets, UP);

% chans = [1:4 9:12 17:20 25:28];
chans = [1];

% for chan = chans
%     sdu = GaussianSmooth2(squeeze(ts(chan,  ups, :)), [5 50], [1 17]); 
% %     sdu = squeeze(ts(chan, ups, :));
%     
%     sdd = GaussianSmooth2(squeeze(ts(chan, ~ups, :)), [5 50], [1 17]); 
% %     sdd = squeeze(ts(chan, ~ups, :));
%     
%     figure;
%     
%     subplot(211);    
%     imagesc(t, tx(ups), sdu);
%     xlabel('time (s)');
%     ylabel('trial');
%     colorbar;
% %     set_colormap_threshold(gcf, [-.2 .2], [-1 1], [.5 .5 .5]);
%     title(num2str(chan));
%     
%     subplot(212);    
%     imagesc(t, tx(ups), sdd);
%     xlabel('time (s)');
%     ylabel('trial');
%     colorbar;
% %     set_colormap_threshold(gcf, [-.2 .2], [-1 1], [.5 .5 .5]);
% end

prettyline(t, squeeze(ts(1,:,:))', lab, 'rgbcmyk');

% % for chan = chans
% %     sdu = GaussianSmooth2(squeeze(ts(chan,  :, :)), [1 50], [1 12]); 
% %     
% %     figure;
% %     
% %     imagesc(t, tx, sdu);
% %     xlabel('time (s)');
% %     ylabel('trial');
% %     ax = colorbar;
% %     set(get(ax,'ylabel'),'String','Norm. HG Power');
% % %     set(ax, 'clabel', 'foo');
% % %     set_colormap_threshold(gcf, [-.2 .2], [-1 1], [.5 .5 .5]);
% %     title(num2str(chan));
% %     
% %     set(hline(runs, 'g--'), 'color', [0.3 0.3 0.3], 'linew', 2);
% %     set(vline(-2, 'k'), 'linew', 1);
% %     set(vline(0, 'k'), 'linew', 2);
% % end
% % 
% % title('PPC Electrode');
% % SaveFig(OUTPUT_DIR, 'S9-PPC-Ex', 'eps', '-r600');
% % SaveFig(OUTPUT_DIR, 'S9-PPC-Ex', 'png', '-r600');

% %%
% 
% len = -Inf;
% 
% for rec = 1:size(timeSeries, 2)
%     len = max(length(timeSeries{1, rec}), len); 
% end
% 
% %%
% ts = nan(size(timeSeries, 1), size(timeSeries, 2), len);
% 
% t = (1:len)/tsfs - 3;
% tx = 1:size(ts, 2);
% 
% rt = t < -2;
% 
% for rec = 1:size(timeSeries, 2)
%     mlen = length(timeSeries{1, rec});
%     
%     temp = [timeSeries{:, rec}]';
%     ts(:, rec, 1:mlen) = log(temp(:, 1:mlen).^2);
% %     mu = nanmean(ts(:, rec, rt),3);
%     
% %     ts(:, rec, :) = ts(:, rec, :) - repmat(mu, [1, 1, size(ts, 3)]);
% end
% 
% %% 
% 
% chans = 1:64;
% ups = ismember(targets, UP);
% 
% ctr = 0;
% for chan = chans
%     ctr=ctr+1;
%     if (ctr==17)
%         ctr=1;
%     end
%     if (ctr==1)
%         figure;
%     end
%     
%     
%     subplot(4,4,ctr);
%     prettyline(t, squeeze(ts(chan, :, :))', ups, 'br');
%     title(num2str(chan));
%     vline(0, 'k');
% end
% 
% %%
% rests = mean(ts(:, ups, t>-2.5&t<-2),3);
% fbs = nanmean(ts(:, ups, t>=.5&t<1.5),3);
% 
% ttest(rests, fbs, 'dim', 2)
% 
% [h, p, ~, tv] = ttest(fbs, rests,'dim', 2, 'alpha', 0.05);
% 
% tv = tv.tstat;
% tv(~h) = 0;
% 
% figure
% PlotDots('9d10c8', {'Grid(:)'}, tv, 'l', [-3 3], 10, 'recon_colormap');
% load('recon_colormap');
% colormap(cm);
% colorbar;

