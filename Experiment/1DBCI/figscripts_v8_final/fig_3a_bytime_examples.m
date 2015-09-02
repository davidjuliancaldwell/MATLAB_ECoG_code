fig_setup;

load (fullfile(cacheOutDir,'tal-brod'));
load (fullfile(cacheOutDir,'tal-hmat'));

% areas = areas';
% areas(~ismember(areas, [8 9 10 46])) = 0;
% 
% M1 = 0; % 1 - M1
% S1 = 4; % 2 - S1
% PMd = 1; % 3 - PMd
% PMv = 2; % 4 - PMv
% PFC = 3; % 5 - PFC
% 
% final = zeros(size(areas))-1;
% 
% final(areas > 0) = PFC;
% final(cdata == 1) = S1;
% final(cdata == 3) = S1;
% final(cdata == 9) = PMd;
% final(cdata == 11) = PMv;
% 
% 
% ctx.tri = cortex.faces;
% ctx.vert = cortex.vertices;
% 
% tripatch(ctx, [], final);
% shading interp;
% light;
% 
% colormap('jet')
% set(gca,'CLim',[0 4]);
% view (90,0);


%% find electrode positions

% fc9643 - S1
Montage.MontageTokenized = {'Grid(18)','psma(16)'};
locs = trodeLocsFromMontage('fc9643', Montage, true);

% 30052b - S5
Montage.MontageTokenized = {'Grid(40)'};
locs = cat(1, locs, trodeLocsFromMontage('30052b', Montage, true));

% % 4568f4 - S4
Montage.MontageTokenized = {'PP(2)'};
locs = cat(1, locs, trodeLocsFromMontage('4568f4', Montage, true));

% % mg - S6
% Montage.MontageTokenized = {'Grid(12)'};
% locs = cat(1, locs, trodeLocsFromMontage('mg', Montage, true));

% 38e116 - S3
% Montage.MontageTokenized = {'Grid(41)'};
% locs = cat(1, locs, trodeLocsFromMontage('38e116', Montage, true));

cats = [3 1 0 2];

locs(:,1) = 1.01*abs(locs(:,1));

figure;
PlotDotsDirect('tail', locs, cats, 'r', [0 3], 10, 'recon_colormap' , [], false);
load('recon_colormap');
colormap(cm);
cb = colorbar('YTickLabel', {'M1','PMd','PMv','PFC'}, 'YTick', 0:3);
set(cb, 'YTickMode', 'manual');
set(cb, 'TickLength', [0 0]);
set(gcf, 'Color', [1 1 1]);
set(cb, 'YLim', [0 3]);
SaveFig(figOutDir, 'overall-examples', 'png', '-r600');

