% load (fullfile(pwd,'cache','tal-brod'));
% load (fullfile(pwd,'cache','tal-hmat'));
% 
% areas = areas';
% areas(~ismember(areas, [8 9 10 46])) = 0;
% 
M1 = 1; % 1 - M1

PMd = 2; % 3 - PMd
PPC = 3; % 4 - PPC
PFC = 4; % 5 - PFC
% 
% final = zeros(size(areas));
% 
% final(areas > 0) = PFC;
% final(cdata == 1) = M1;
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

%% find electrode positions

% fc9643 - S1 19 YES
Montage.MontageTokenized = {'Grid(18)','psma(16)'};
locs = trodeLocsFromMontage('fc9643', Montage, true);

% 4568f4 - S4
Montage.MontageTokenized = {'PP(2)'};
locs = cat(1, locs, trodeLocsFromMontage('4568f4', Montage, true));

% 30052b - S5
Montage.MontageTokenized = {'Grid(40)'};
locs = cat(1, locs, trodeLocsFromMontage('30052b', Montage, true));

cats = [PFC PMd PPC M1];

figure;
PlotDotsDirect('tail', locs, cats, 'r', [M1 PFC], 10, 'recon_colormap', [], false);
load('recon_colormap');
colormap(cm);
cb = colorbar('YTickLabel', {'M1','PMd','PPC','PFC'}, 'YTick', 1:4);
set(cb, 'YTickMode', 'manual');
set(cb, 'TickLength', [0 0]);
set(gcf, 'Color', [1 1 1]);

SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), 'overall-examples', 'png');

