% load (fullfile(pwd,'cache','tal-brod'));
% load (fullfile(pwd,'cache','tal-hmat'));
% 
% areas = areas';
% areas(~ismember(areas, [8 9 10 46])) = 0;
% 
% M1 = 1; % 1 - M1
% S1 = 2; % 2 - S1
% PMd = 3; % 3 - PMd
% PMv = 4; % 4 - PMv
% PFC = 5; % 5 - PFC
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

% 30052b - S5
Montage.MontageTokenized = {'Grid(10)'};
locs = trodeLocsFromMontage('30052b', Montage, true);

% mg - S6
Montage.MontageTokenized = {'MiniGrid(2)'};
locs = cat(1, locs, trodeLocsFromMontage('mg', Montage, true));

% 4568f4 - S4
Montage.MontageTokenized = {'Grid(3)', 'PST(4)'};
locs = cat(1, locs, trodeLocsFromMontage('4568f4', Montage, true));

locs(:,1) = abs(locs(:,1));

figure;
PlotDotsDirect('tail', locs, ones(size(locs,1),1), 'r', [0 1], 10, 'recon_colormap', [], false);
% load('recon_colormap');
% colormap(cm);
% cb = colorbar('YTickLabel', {'M1','S1','PMd','PMv','PFC'}, 'YTick', 1:5);
% set(cb, 'YTickMode', 'manual');
% set(cb, 'TickLength', [0 0]);
% set(gcf, 'Color', [1 1 1]);

SaveFig(fullfile(pwd, 'figs'), 'other-examples', 'png');

