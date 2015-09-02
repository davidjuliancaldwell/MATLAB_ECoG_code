% s = 1; c = 28
figure
plot(t,X(:,c),'color',[.8 .8 1]);
hold on;
plot(t,Xs(:,c),'color',[0 0 1], 'linew', 2);

vline(0,'k:')

set(hline(lowest, 'k--'), 'color', [.5 .5 .5]);
ax = hline(highest, 'k--');
set(ax, 'color', [.5 .5 .5]);
legendOff(ax);

set(hline((highest+lowest)/2,'r--'), 'linew', 2);

plot(t(onsets(c)), (highest+lowest)/2, 'ro', 'linew', 2);
legendOff(plot(t(onsets(c)), (highest+lowest)/2, 'ro', 'linew', 2, 'markersize', 20));

legend('Original HG', 'Smoothed HG', 'Cue Presentation', 'Post-Cue Bounds', 'Onset Threshold', 'Onset', 'location', 'northwest');
xlabel('Time (s)');
ylabel('HG amplitude');
title('Trial realignment');

SaveFig('d:\research\code\output\RJB_Interactions\figures', 'realignment ex', 'eps', '-r600');
