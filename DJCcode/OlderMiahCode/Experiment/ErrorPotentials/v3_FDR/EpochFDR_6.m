%% EpochFDR

%% basic setup: provide the subjid you want to run for
subjid = '4568f4';

%%

TouchDir(fullfile(subjid, 'stats'));
load(fullfile(subjid, [subjid '_decomp.mat']), 'bads', 'tgts', 'ress', 'Montage', 't', 'fw');

interesting = zeros(max(cumsum(Montage.Montage)), 1);

clear h p final_p tstats;

for chan = 1:max(cumsum(Montage.Montage))
    if (~ismember(chan, bads))
        fprintf('working on channel %d\n', chan);
        
        fprintf('loading... ');
        load(fullfile(subjid, 'chan', sprintf('%d.mat', chan)), 'decompAll');
        fprintf('done\n');
        
        dca = abs(decompAll);

        if (~exist('h','var'))
            h = zeros(size(dca,1), size(dca,2), length(interesting));
            p = zeros(size(dca,1), size(dca,2), length(interesting));
            final_p = zeros(length(interesting), 1);
            tstats = zeros(size(dca,1), size(dca,2), length(interesting));
        end
        
        [h(:,:,chan), p(:,:,chan), ~, bstats] = ttest2(dca(:,:,tgts==ress), dca(:,:,tgts~=ress), 0.05, 'both', 'unequal', 3);
        tstats(:,:,chan) = bstats.tstat;
        
        [final_p(chan)] = fdr(p(:,:,chan), 0.05);
        
        if (final_p(chan) > 0)
            interesting(chan) = 1;
        end
    end    
end

save(fullfile(subjid, 'stats', [subjid '_stats.mat']), 'final_p', 'p', 'h', 'tstats', 'interesting');
    
%% display features of interest and mean feature tstats on whole brain
load(fullfile(subjid, 'stats', [subjid '_stats.mat']), 'final_p', 'p', 'h', 'tstats', 'interesting');
load(fullfile(subjid, [subjid '_decomp.mat']), 'Montage', 't', 'fw');


mtx = repmat(shiftdim(final_p, -2), [size(p,1), size(p,2), 1]);
mask = p < mtx;
tstat_masked = tstats;
tstat_masked(~mask) = 0;

itrodes = find(interesting);

dim1 = ceil(sqrt(length(itrodes)));
dim2 = dim1;

if ((dim1^2 - length(itrodes)) > (dim1*(dim1-1) - length(itrodes)))
    dim2 = dim1-1;
end

h_trodes = figure;

cl = max(max(max(abs(tstat_masked))));
load('recon_colormap');

for c = 1:length(itrodes)
    subplot(dim1,dim2,c);
    imagesc(t,fw,squeeze(tstat_masked(:,:,itrodes(c)))'); axis xy;
    colormap(cm);
%     colorbar;
    title(trodeNameFromMontage(itrodes(c), Montage));
    set(gca, 'CLim', [-cl cl]);
end

maximize;
mtit(subjid, 'xoff', 0, 'yoff', 0.025);
SaveFig(fullfile(subjid, 'figs'), [subjid '_tstat_map'], 'eps');
    

h_brain = figure;

tstat_masked(tstat_masked==0)=NaN;

weightsHG = squeeze(nansum(nansum(tstat_masked(:, fw>70,:),1),2));
weightsLF = squeeze(nansum(nansum(tstat_masked(:, fw<18,:),1),2));

weightsHG(weightsHG==0) = NaN;
weightsLF(weightsLF==0) = NaN;

[~,~,side] = filesForSubjid(subjid);

subplot(221);
PlotDots(subjid, Montage.MontageTokenized, weightsHG, side, [-nanmax(abs(weightsHG)) nanmax(abs(weightsHG))], 20, 'recon_colormap');
view(90,0);
title('high frequency feature tstats');
subplot(222);
PlotDots(subjid, Montage.MontageTokenized, weightsHG, side, [-nanmax(abs(weightsHG)) nanmax(abs(weightsHG))], 20, 'recon_colormap');
view(270,0);
title('high frequency feature tstats');
subplot(223);
PlotDots(subjid, Montage.MontageTokenized, weightsLF, side, [-nanmax(abs(weightsLF)) nanmax(abs(weightsLF))], 20, 'recon_colormap');
view(90,0);
title('low frequency feature tstats');
subplot(224);
PlotDots(subjid, Montage.MontageTokenized, weightsLF, side, [-nanmax(abs(weightsLF)) nanmax(abs(weightsLF))], 20, 'recon_colormap');
view(270,0);
title('low frequency feature tstats');

SaveFig(fullfile(subjid, 'figs'), [subjid '_tstat_brain'], 'png');



    
