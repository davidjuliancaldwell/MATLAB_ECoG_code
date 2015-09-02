% %% load data
subjid = '30052b';
load(fullfile(subjid, [subjid '_epochs_clean']));

%% review all epochs
% process on a channel by channel basis
t = -3:1/fs:4; % this is currently a hack, need to specify actual trial times
fw = [1:5:200];
% fw = [1 6 10 18 70:20:200];
L = 5;

hits = tgts==ress;
misses = ~hits;

rsas = zeros(size(epochs, 1), size(epochs, 3), length(fw));
hitValues = zeros(size(epochs, 1), size(epochs, 3), length(fw));
missValues = zeros(size(epochs, 1), size(epochs, 3), length(fw));

TouchDir(fullfile(subjid, 'chan'));

for c = 1:size(epochs, 1)
    fprintf('channel %d\n', c);
    data = squeeze(epochs(c, :, :)); 
    
    [decompAvg, ~, decompAll, ~] = time_frequency_wavelet(data', fw, fs, 0, 1, 'CPUtest');    
    
    decompAll = abs(decompAll);

%     decompAvg2 = smoothAndDownsample(decompAvg, L, 1);
%     decompAll2 = smoothAndDownsample(decompAll, L, 1);
%     t2 = t(1:L:end);
    
    if (~ismember(c, bads))
        save(fullfile(subjid, 'chan', num2str(c)), 'decompAll');
    end
    
%     decompAll = abs(decompAll);
    
%     rsas = zeros(size(decompAll, 1), size(decompAll, 2));
    
    for d = 1:length(fw)
        rsas(c, :, d) = signedSquaredXCorrValue(squeeze(decompAll(:,d,hits)), squeeze(decompAll(:,d,misses)), 2);
    end
    
    hitValues(c, :, :) = squeeze(mean(decompAll(:,:,hits), 3));
    missValues(c, :, :) = squeeze(mean(decompAll(:,:,misses), 3));

end

clear ans c d data decompAll decompAvg epochs
save(fullfile(subjid, [subjid '_decomp']));

%% display one at a time
load(fullfile(subjid, [subjid '_decomp']));

clims = [-max(max(max(abs(rsas)))) max(max(max(abs(rsas))))];

for c = 1:size(rsas,1)
    if (~ismember(c, bads))
        figure;
        imagesc(t, fw, -squeeze(rsas(c,:,:))');
        set(gca, 'clim', clims);
        title(sprintf('%d : %s', c, trodeNameFromMontage(c, Montage)));

        axis xy;    
        colorbar;
        set_colormap_threshold(gcf, clims/10, clims, [1 1 1]);
        pause
        close
    end
end



%% list the interesting electrodes

% % list = [20 97 98]; % 9ad250
% list = [7 8 12 16 20 32 54 88]; % fc
% % list = [2 14 33 37 47 57 58 62 66 85 95 96]; % 4568f4
% % list = [7 18 19 27 28 35 50 69 79 ]; % 30052b

list = getElectrodeList(subjid);

%% display info
% load(fullfile(subjid, [subjid '_decomp.mat']));

% dim = ceil(sqrt(length(list)));
% 
% clims = [-max(max(max(abs(rsas)))) max(max(max(abs(rsas))))];
% 
% figure;
% for c = 1:length(list)
%     subplot(dim, dim, c);
%     
%     imagesc(t, fw, -squeeze(rsas(list(c),:,:))');
%     set(gca, 'clim', clims);
%     title(trodeNameFromMontage(list(c), Montage));
% 
%     axis xy;    
%     colorbar;
% end
% 
% set_colormap_threshold(gcf, clims/10, clims, [1 1 1]);
% 
% maximize;
% mtit('patterns of activity change in failed trials rel. successful trials', 'xoff', 0, 'yoff', 0.025);

% %% do summary plots for each channel independently
% % include hg for hits/misses
% % normalized tfa for hits/misses
% % error rsas
% % load(fullfile(subjid, [subjid '_decomp']));
% 
% rsaclims = [-max(max(max(abs(rsas)))) max(max(max(abs(rsas))))];
% 
% for c = 1:length(list)
%     if (~ismember(list(c), bads))
%         figure; maximize;
%         subplot(321);
%         
%         hitHG = squeeze(mean(hitValues(list(c), :, fw > 70 & fw < 100),3));
%         missHG = squeeze(mean(missValues(list(c), :, fw > 70 & fw < 100),3));
%         hitBeta = squeeze(mean(hitValues(list(c), :, fw > 12 & fw < 30),3));
%         missBeta = squeeze(mean(missValues(list(c), :, fw > 12 & fw < 30),3));
%         hitLow = squeeze(mean(hitValues(list(c), :, fw < 12),3));
%         missLow = squeeze(mean(missValues(list(c), :, fw < 12),3));
%         
%         hitHG([1:100 (end-100):end]) = mean(hitHG);
%         missHG([1:100 (end-100):end]) = mean(missHG);
%         
%         nHGs = normTo([hitHG missHG], 2,3);
%         nBetas = normTo([hitBeta missBeta], 1,2);
%         nLows = normTo([hitLow missLow], 0,1);
%         
%         plot(t, nHGs(1:length(hitHG)), 'b'); hold on;
%         plot(t, nHGs((length(hitHG)+1):end), 'r');
%         plot(t, nBetas(1:length(hitBeta)), 'b--');
%         plot(t, nBetas((length(hitBeta)+1):end), 'r--');
%         plot(t, nLows(1:length(hitLow)), 'b:');
%         plot(t, nLows((length(hitLow)+1):end), 'r:');
%         title('response');
%         xlabel('time (s)');
%         ylabel('normalized power (arb.)');
%         legend('\gamma_h', '\gamma_m', '\beta_h', '\beta_m', '<\beta_h', '<\beta_m', 'Location', 'EastOutside');
%         
%         
%         subplot(322);
%         normVals = normalize_plv(squeeze(hitValues(list(c), :, :))', squeeze(hitValues(list(c), t > -2.8 & t < -2, :))');
%         imagesc(t, fw, normVals);
%         axis xy;
%         set_colormap_threshold(gca, [-2 2], [-20 20], [1 1 1]);        
%         title('average hit (z)');
%         xlabel('time (s)');
%         ylabel('frequency (Hz)');
%         colorbar;
%         
%         subplot(324);
%         normVals = normalize_plv(squeeze(missValues(list(c), :, :))', squeeze(missValues(list(c), t > -2.8 & t < -2, :))');        
%         imagesc(t, fw, normVals);
%         axis xy;
%         set_colormap_threshold(gca, [-2 2], [-20 20], [1 1 1]);        
%         title('average miss (z)');
%         xlabel('time (s)');
%         ylabel('frequency (Hz)');
%         colorbar;
%         
%         subplot(323);
%         imagesc(t, fw, -squeeze(rsas(list(c),:,:))');
%         set(gca, 'clim', rsaclims);
%         axis xy;    
% %         set_colormap_threshold(gca, [-0.1 0.1], [-0.2 0.2], [1 1 1]);
%         title('significant differences (r^2)');
%         xlabel('time (s)');
%         ylabel('frequency (Hz)');
%         colorbar;
%         pos3 = get(gca, 'Position');
%         
%         subplot(321);
%         pos1 = get(gca, 'Position');
%         pos1(3) = pos3(3);
%         set(gca, 'Position', pos1);
%         
%         subplot(325);
%         PlotDotsDirect(subjid, Montage.MontageTrodes(list(c),:), 1, hemi, [0 1]);
%         view(90, 0);
%         
%         subplot(326);
%         PlotDotsDirect(subjid, Montage.MontageTrodes(list(c),:), 1, hemi, [0 1]);
%         view(270, 0);
%         
%         mtit(trodeNameFromMontage(list(c), Montage));
%         
% %         saveas(gcf, fullfile(subjid, [trodeNameFromMontage(list(c), Montage) '.png']), 'png');
%         SaveFig(subjid, trodeNameFromMontage(list(c), Montage), 'png');
% %         close;
%     end
% end
% 
%% plot them all on the talairach brain for comparison of location
alltrodes = [];
allvals = [];

sids = {'9ad250','fc9643','4568f4','30052b'};
lists = {[20 97 98], ...
    [8 12 13 16 20 32 56 88], ...
    [2 33 37 47 57 58 59 62 66 85 95 96], ...
    [7 14 18 19 27 28 48 50 69 79]};

for c = 1:length(sids)
    subjid = sids{c};
    list = lists{c};
    
    load(fullfile(subjid, [subjid '_epochs.mat']), 'Montage');
    locs = trodeLocsFromMontage(subjid, Montage, true);
    alltrodes = cat(1, alltrodes, locs(list, :));
    allvals = cat(1, allvals, c*ones(size(list))');
end

PlotDotsDirect('tail', alltrodes, allvals, 'both', [1 4], 20, 'recon_colormap', [], false);
view(90,0);
SaveFig(pwd, 'all-r', 'png');
view(270,0);
SaveFig(pwd, 'all-l', 'png');
% todo actually plot on the brain