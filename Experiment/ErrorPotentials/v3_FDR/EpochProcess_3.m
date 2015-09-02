%% do wavelet based decomposition of all epochs

% %% In the case where we are not running directly from EpochCollect, we
% % will need to load in data, though this takes a while, so the default
% % assumption is that you have just run EpochCollect
subjid = 'fc9643';
[~, odir] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_epochs_clean']));

%% review all epochs
% process on a channel by channel basis
fw = [1:5:200];

hits = tgts==ress;
misses = ~hits;

hitValues = zeros(size(epochs, 1), size(epochs, 3), length(fw));
missValues = zeros(size(epochs, 1), size(epochs, 3), length(fw));

TouchDir(fullfile(odir, 'chan'));

for c = 1:size(epochs, 1)
    fprintf('channel %d\n', c);
    data = squeeze(epochs(c, :, :)); 
    
    [~, ~, decompAll, ~] = time_frequency_wavelet(data', fw, fs, 0, 1, 'CPUtest');    
    
    decompAll = abs(decompAll);

    if (~ismember(c, bads))
        save(fullfile(odir, 'chan', num2str(c)), 'decompAll');
    end
    
    hitValues(c, :, :) = squeeze(mean(decompAll(:,:,hits), 3));
    missValues(c, :, :) = squeeze(mean(decompAll(:,:,misses), 3));

end

clear ans c d data decompAll decompAvg epochs
save(fullfile(odir, [subjid '_decomp']));

% %% display one at a time
% 
% load(fullfile(odir, [subjid '_decomp']));
% 
% clims = [-max(max(max(abs(rsas)))) max(max(max(abs(rsas))))];
% 
% for c = 1:size(rsas,1)
%     if (~ismember(c, bads))
%         figure;
%         imagesc(t, fw, -squeeze(rsas(c,:,:))');
%         set(gca, 'clim', clims);
%         title(sprintf('%d : %s', c, trodeNameFromMontage(c, Montage)));
% 
%         axis xy;    
%         colorbar;
%         set_colormap_threshold(gcf, clims/10, clims, [1 1 1]);
%         pause
%         close
%     end
% end


% %% plot them all on the talairach brain for comparison of location
% alltrodes = [];
% allvals = [];
% 
% sids = {'9ad250','fc9643','4568f4','30052b'};
% 
% for c = 1:length(sids)
%     subjid = sids{c};
%     [~, odir] = filesForSubjid(subjid);
% 
%     list = getElectrodeList(subjid);
% %     list = lists{c};
%     
%     load(fullfile(odir, [subjid '_epochs.mat']), 'Montage');
%     locs = trodeLocsFromMontage(subjid, Montage, true);
%     alltrodes = cat(1, alltrodes, locs(list, :));
%     allvals = cat(1, allvals, c*ones(size(list))');
% end
% 
% PlotDotsDirect('tail', alltrodes, allvals, 'both', [1 4], 20, 'recon_colormap', [], false);
% view(90,0);
% SaveFig(pwd, 'all-r', 'png');
% view(270,0);
% SaveFig(pwd, 'all-l', 'png');
% 
