%%
Z_Constants;
addpath ./scripts

%%

open(fullfile(OUTPUT_DIR, 'Grand_average_bplv.fig'));

set(gcf, 'pos', [380   260   860   695]);

xlabel('time (s)', 'fontsize', 18);
ylabel('Group average \alpha-HG bPLV', 'fontsize', 18);

ls = findobj(gca, 'type','line');
ch = get(gca, 'children');

% change to black and white
% ls(1) is the down target line, ls(2) is the upper line on the boundary
% for down targets, ls(3) is the lower
% ls(4)is the up target line, ls(5) is the upper line on the boundary
% for up targets, ls(6) is the lower

% change alpha values
set(get(ch(4), 'children'), 'facealpha', .5)
set(get(ch(9), 'children'), 'facealpha', .5)

set(vline(0, 'k'), 'linew', 2)
set(gca, 'fontsize', 14);

title('Up vs. Down bPLV', 'fontsize', 18);

SaveFig(OUTPUT_DIR, 'Grand_average_bplv_mod_col', 'eps', '-r600');

% move the legend
set(findobj(gcf, 'Tag', 'legend'), 'location', 'northwest');

set(ls(1), 'LineStyle', '--', 'color', [.5 .5 .5]);
set(ls(2), 'color', [.5 .5 .5]);
set(ls(3), 'color', [.5 .5 .5]);

set(ls(4), 'LineStyle', '-', 'color', [0 0 0]);
set(ls(5), 'color', [0 0 0]);
set(ls(6), 'color', [0 0 0]);

set(get(ch(4), 'children'), 'facecolor', [.5 .5 .5]);
set(get(ch(9), 'children'), 'facecolor', [0 0 0]);

save(fullfile(OUTPUT_DIR, 'Grand_average_bplv_mod.fig'));

SaveFig(OUTPUT_DIR, 'Grand_average_bplv_mod', 'eps', '-r600');

%%

open(fullfile(OUTPUT_DIR, 'bplv_grp_average_early_vs_late.fig'));

set(gcf, 'pos', [380   260   860   695]);

xlabel('time (s)', 'fontsize', 18);
ylabel('Group average \alpha-HG bPLV', 'fontsize', 18);

ls = findobj(gca, 'type','line');
ch = get(gca, 'children');

% change alpha values
set(get(ch(4), 'children'), 'facealpha', .5)
set(get(ch(9), 'children'), 'facealpha', .5)

set(vline(0, 'k'), 'linew', 2)
set(gca, 'fontsize', 14);

title('Early vs. Late bPLV', 'fontsize', 18);

% move the legend
set(findobj(gcf, 'Tag', 'legend'), 'location', 'northwest');

SaveFig(OUTPUT_DIR, 'bplv_grp_average_early_vs_late_mod_col', 'eps', '-r600');

% change to black and white
% ls(1) is the down target line, ls(2) is the upper line on the boundary
% for down targets, ls(3) is the lower
% ls(4)is the up target line, ls(5) is the upper line on the boundary
% for up targets, ls(6) is the lower
set(ls(1), 'LineStyle', '--', 'color', [.5 .5 .5]);
set(ls(2), 'color', [.5 .5 .5]);
set(ls(3), 'color', [.5 .5 .5]);

set(ls(4), 'LineStyle', '-', 'color', [0 0 0]);
set(ls(5), 'color', [0 0 0]);
set(ls(6), 'color', [0 0 0]);

set(get(ch(4), 'children'), 'facecolor', [.5 .5 .5]);
set(get(ch(9), 'children'), 'facecolor', [0 0 0]);

save(fullfile(OUTPUT_DIR, 'bplv_grp_average_early_vs_late_mod.fig'));

SaveFig(OUTPUT_DIR, 'bplv_grp_average_early_vs_late_mod', 'eps', '-r600');


