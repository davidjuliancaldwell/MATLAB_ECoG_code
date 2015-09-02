tcs;

%%
% load('d:\research\code\gridlab\Experiment\1DBCI\figscripts_v3\cache\fig_bytime.30052b.mat')

%%
tempwin = squeeze(allwindows(:,22,:));

upwin = tempwin(:,alltargets==1);
dnwin = tempwin(:,alltargets==2);

figure;
% plot(t, mean(upwin,2),'Color', theme_colors(red,:), 'LineStyle', ':'); 
plot(t, mean(dnwin,2),'Color', theme_colors(blue,:), 'LineStyle', ':');
hold on;

sup = GaussianSmooth(mean(upwin,2),250);
sdn = GaussianSmooth(mean(dnwin,2),250);

% plot(t, sup,'Color', theme_colors(red,:), 'LineWidth',8);
plot(t, sdn,'Color', theme_colors(blue,:), 'LineWidth',8);

axis off;
axis tight;

ylims = ylim;

plot([0 0], ylims, 'Color', theme_colors(7,:), 'LineWidth', 4);
plot([fb fb], ylims, 'Color', theme_colors(7,:), 'LineWidth', 4);

plot([t(20) t(20)], ylims, 'k', 'LineWidth', 4);
plot([t(1)+1 t(1)+1], ylims, 'k', 'LineWidth', 4);
set(gcf, 'Color', [1 1 1]);
