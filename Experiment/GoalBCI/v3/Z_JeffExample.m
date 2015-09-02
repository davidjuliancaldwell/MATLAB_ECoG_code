Z_Constants;

load('D:\research\code\output\GoalBCI\meta\6b68ef-epochs.mat');
subplot(411);

x = paths{121};
x(1:find(t>0,1,'first')) = .5;
plot(t(1:length(paths{121})), x, 'linew', 2);
hold on;
plot(t(1:length(paths{121})), targetY{121},'k');
plot(t(1:length(paths{121})), targetY{121}+targetD{121}/2,'k:');
plot(t(1:length(paths{121})), targetY{121}-targetD{121}/2,'k:');
vline(0);
vline(t(length(paths{121}))-postDur);
title('cursor path and target location');
legend('trajectory', 'target center', 'target edge', 'location', 'northwest')

subplot(412);
y = [0; diff(paths{121})];
y(1:(find(t>0,1,'first')+1)) = NaN;
plot(t(1:length(paths{121})), y, 'linew', 2);
vline(0);
vline(t(length(paths{121}))-postDur);
title('cursor velocity');
% legend('velocity', 'location', 'northwest')


subplot(413);
y = abs(diffs{121});
y(1:find(t>0,1,'first')) = NaN;
plot(t(1:length(paths{121})), y, 'linew', 2);
vline(0);
vline(t(length(paths{121}))-postDur);
title('root-mean-squared-error');
% legend('error', 'location', 'northwest')

subplot(414);
z = data{cchan, 121};
plot(t(1:length(paths{121})), z, 'linew', 2);
title('High-gamma');
vline(0);
vline(t(length(paths{121}))-postDur);
% legend('ex. HG', 'location', 'northwest')

set(gcf, 'pos', [  624   257   861   721]);
SaveFig(OUTPUT_DIR, 'jeff-ex', 'png');

%%
load('D:\research\code\output\GoalBCI\meta\6b68ef-xcorr-results.mat')

x = lags/fs;
y = mean(vCorr(:,:,cchan),2);

plot(fliplr(x), fliplr(y));
ub = prctile(vDistro(:,1), 97.5);
lb = prctile(vDistro(:,2), 2.5);
hold on;
plot([min(x), max(x)], [ub ub], 'r:');
plot([min(x), max(x)], [lb lb], 'r:');
legend('xcorr', 'significance thresholds', 'location', 'northeast');

xlabel('lag (sec)');
ylabel('normalized cross-correlation coefficient');
title('velocity and HG (control chan)');

SaveFig(OUTPUT_DIR, 'jeff-ex2', 'png');