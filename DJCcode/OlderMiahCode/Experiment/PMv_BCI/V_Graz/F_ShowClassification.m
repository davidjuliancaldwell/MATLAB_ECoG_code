Z_Constants;
addpath ./scripts;


load(fullfile(META_DIR, 'areas.mat'));

%% show the electrodes that made the cut

alllocs = [];
allweights = [];
labels = [];

for idx = 1:length(SIDS)
    sid = SIDS{idx};
    [~,hemi,~,Montage,cchan] = filesForSubjid(sid);
    
    load(fullfile(META_DIR, sprintf('%s_results.mat', sid)), 'class');
    
    tlocs = trodeLocsFromMontage(sid, Montage, true);
    
%     cchans = cat(1, cchans, tlocs(cchan, :));
%     trs = cat(1, trs, tlocs(trodesOfInterest{idx}, :));        
    
    trs = trodesOfInterest{idx};
    trodes = [cchan; trs(trs ~= cchan)];

    alllocs = cat(1, alllocs, tlocs(trodes, :));    
    mclasses = class(trodes);
    mclasses(1) = -1; % force the control electrode to -1;
    
    allweights = cat(1, allweights, mclasses);
    labels = cat(1, labels, idx*ones(size(mclasses)));
end

fprintf('total number of PMv trodes considered: %d\n', sum(allweights>= 0));
fprintf('  total number of non-modulated PMv trodes: %d\n', sum(allweights==0));
fprintf('  total number of control-like PMv trodes: %d\n', sum(allweights==1));
fprintf('  total number of effort PMv trodes: %d\n', sum(allweights==2));

figure
% alllocs = cat(1, cchans, trs);
% allweights = cat(1, zeros(size(cchans, 1),1), ones(size(trs, 1),1));


cm = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
save('temp_colormap.mat','cm');
side = (alllocs(:, 1) < 0)+1;
alllocs(:,1) = abs(alllocs(:,1))+3;
PlotDotsDirectWithCustomMarkers('tail', alllocs, allweights, 'r', [-2 2], 10, side, 'temp_colormap', labels, false);
cax = colorbar;
% load('recon_colormap');
colormap(cm);
delete ('temp_colormap.mat');

set(cax, 'ytick', [-1 0 1 2]);
set(cax, 'yticklabel', {'control site', 'non-modulated', 'control-like', 'effort-like'});
maximize;
SaveFig(OUTPUT_DIR, 'trode_choice_r', 'png', '-r600');

% %%
% figure
% PlotDotsDirectWithCustomMarkers('tail', alllocs(allweights~=0, :), allweights(allweights~=0), 'r', [-1 2], 10, side(allweights~=0), 'recon_colormap', labels, false);
% cax = colorbar;
% load('recon_colormap');
% colormap(cm);
% set(cax, 'ytick', [-1 1 2]);
% set(cax, 'yticklabel', {'ctl', 'ctl-like', 'effort'});
% maximize;
% SaveFig(OUTPUT_DIR, 'trode_choice_r_no_null', 'png', '-r600');
% 
