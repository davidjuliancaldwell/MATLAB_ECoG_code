%% plot them all on the talairach brain for comparison of location
alltrodes_hg = [];
allvals_hg = [];

sids = {'38e116', 'fc9643','4568f4','30052b', '9ad250'};
% sids = {'fc9643','4568f4'};
figure;

for c = 1:length(sids)
    
  
    subjid = sids{c}; 
    [~, odir] = filesForSubjid(subjid);
    
    load(fullfile(odir, 'significant_clusters.mat'), 'clusterChans*');
    load(fullfile(odir, [subjid '_epochs_clean.mat']), 'Montage');

%     list = union(find(clusterChans_hg == 1), find(clusterChans_beta == 1));
    list = find(clusterChans_hg == 1);
    
    list = list(list < max(cumsum(Montage.Montage)));

%     warning('hack in place');
%     if (strcmp(subjid, '4568f4'))
%         list = list(list <= 64);
%     end
    
    locs = trodeLocsFromMontage(subjid, Montage, true);
    
    alltrodes_hg = cat(1, alltrodes_hg, locs(list, :));
    allvals_hg = cat(1, allvals_hg, c*ones(size(list))');
end

% alltrodes(:,1) = abs(alltrodes(:,1));

% subplot(211);
PlotDotsDirect('tail', alltrodes_hg, allvals_hg, 'r', [1 length(sids)], 10, 'temp_colormap', [], false);
view(90,0);
load('temp_colormap');
colormap(cm);

% title('Spatial distribution of error responses', 'FontSize', 9);

% subplot(212);
% PlotDotsDirect('tail', alltrodes, allvals, 'r', [1 length(sids)], 10, 'recon_colormap', [], false);
% view(270,0);

% SaveFig(pwd, 'all-r', 'png');
% SaveFig(pwd, 'all-l', 'png');
% todo actually plot on the brain

load('recon_colormap');
colormap(cm);