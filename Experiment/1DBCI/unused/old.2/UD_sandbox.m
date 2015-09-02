figure;
ax(1) = subplot(411);
plot(sta.Feedback)
ylim(ylim + [-0.2 0.2]);
title('feedback');

ax(2) = subplot(412);
% ypos = sta.CursorPosY / max(sta.CursorPosY);
ypos = double(sta.CursorPosY);
plot(ypos, 'g');
ylim(ylim + [-0.2 0.2]);
title('cursor position');

ax(3) = subplot(413);
plot(sta.TargetCode, 'c');
ylim(ylim + [-0.2 0.2]);
title('target code');

ax(4) = subplot(414);
adapt = double(sta.Yadapt);
adapt(sta.Yadapt > 2) = -1;
plot(adapt, 'r:');
ylim(ylim + [-0.2 0.2]);
title('adaptation');

linkaxes(ax, 'x');