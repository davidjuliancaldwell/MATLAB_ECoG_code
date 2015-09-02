Z_Constants;
addpath ./scripts;


load(fullfile(META_DIR, 'areas.mat'));

%% show the electrodes that made the cut

alllocs = [];
allweights = [];
labels = [];

for idx = 1:length(SIDS)
    sid = SIDS{idx};
    load(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)), 'tlocs', 'class');

    class(1) = -1; % force the control electrode to -1;
    
    allweights = cat(1, allweights, class);
    alllocs = cat(1, alllocs, tlocs);
    labels = cat(1, labels, idx*ones(size(class)));
end

fprintf('total number of trodes considered: %d\n', sum(allweights>= 0));
fprintf('  total number of non-modulated trodes: %d\n', sum(allweights==0));
fprintf('  total number of control-like trodes: %d\n', sum(allweights==1));
fprintf('  total number of effort trodes: %d\n', sum(allweights==2));
fprintf('  total number of inverse trodes: %d\n', sum(allweights==3));

%%
figure

side = (alllocs(:, 1) < 0)+1;
alllocs = projectToHemisphere(alllocs, 'r');

PlotDotsDirectWithCustomMarkers('tail', alllocs, allweights, 'r', [-1 3], 10, side, 'recon_colormap', labels, false);
cax = colorbar;
load('recon_colormap');
colormap(cm);


set(cax, 'ytick', [-1 0 1 2 3]);
set(cax, 'yticklabel', {'control site', 'non-modulated', 'control-like', 'effort-like', 'inverted'});
maximize;

%%
SaveFig(OUTPUT_DIR, 'trode_choice_r', 'png', '-r600');
