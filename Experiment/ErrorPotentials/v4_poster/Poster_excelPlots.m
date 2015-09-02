
% predata = ...
% [22	0.776	0.747	0.306	0.929; ...
% 7	0.742	0.736	0.266	0.931; ...
% 9	0.840	0.774	0.285	0.96; ...
% 2	0.840	0.809	0.083	0.974; ...
% NaN NaN NaN NaN NaN];

predata = ...
[22	0.681	0.75	0.657	0.687;...
7	0.707	0.735	0.696	0.712;...
9	0.699	0.78	0.664	0.706;...
2	0.686	0.731	0.487	0.699;...
NaN NaN NaN NaN NaN];

% redata = ...
% [47	0.836	0.861	0.608	0.904; ...
% 36	0.821	0.867	0.669	0.885; ...
% 20	0.854	0.801	0.411	0.953; ...
% 3	0.872	0.744	0.242	0.982; ...
% 5	0.645	0.694	0.382	0.838];

redata = ...
[47	0.823	0.871	0.813	0.827;...
36	0.793	0.87	0.746	0.801;...
20	0.764	0.831	0.723	0.771;...
3	0.750	0.828	0.463	0.768;...
5	0.651	0.7	0.638	0.659];


FEATCT = 1;
ACC = 2;
AUC = 3;
SENS = 4;
SPEC = 5;

[~, odir] = filesForSubjid('fc9643');

% do the redata plot
figure;

[~, idxs] = sort(predata(:,FEATCT));

ax = plot(predata(idxs,FEATCT), predata(idxs,ACC:SPEC)-0.005, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'color', 'k');
hold on;
legendOff(ax);
plot(predata(idxs,FEATCT), predata(idxs,ACC:SPEC), '.-', 'MarkerSize', 30, 'LineWidth', 3);
% legend('accuracy', 'AUC', 'sensitivity', 'specificity', 'Location', 'Southeast');

set(gca, 'FontSize', 14);
title('Impact of feature # on predictive classification', 'FontSize', 18);
xlabel('Feature #', 'FontSize', 18);

SaveFig(fullfile(fileparts(odir), 'figs'), 'prevscount.eps', 'eps', '-r600');

% do the redata plot
figure;

[~, idxs] = sort(redata(:,FEATCT));

ax = plot(redata(idxs,FEATCT), redata(idxs,ACC:SPEC)-0.005, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'color', 'k');
hold on;
legendOff(ax);
plot(redata(idxs,FEATCT), redata(idxs,ACC:SPEC), '.-', 'MarkerSize', 30, 'LineWidth', 3);
legend('accuracy', 'AUC', 'sensitivity', 'specificity', 'Location', 'Southeast');

set(gca, 'FontSize', 14);
title('Impact of feature # on reactive classification', 'FontSize', 18);
xlabel('Feature #', 'FontSize', 18);
SaveFig(fullfile(fileparts(odir), 'figs'), 'revscount.eps', 'eps', '-r600');
