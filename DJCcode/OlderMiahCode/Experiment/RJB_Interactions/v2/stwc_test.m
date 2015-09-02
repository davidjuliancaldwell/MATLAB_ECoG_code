fs = 1200;
t = -3:(1/fs):4;

a = randn(length(t),1);
b = randn(length(t),1);

achange = find(t>0, 1, 'first');
bchange = find(t>0.10, 1, 'first');
revert = find(t > 3, 1, 'first');

a (achange:revert) = a(achange:revert) +1;
b (bchange:revert) = b(bchange:revert) +1;

% introduce correlation
a(bchange:revert) = a(bchange:revert) +1 * (b(bchange:revert)-1);

a = GaussianSmooth(a, round(.1 * fs));
b = GaussianSmooth(b, round(.1 * fs));

winsize = round(.500*fs);
maxlag = round(.3*fs);

% outCor = gausswc(single(a),single(b), winsize, maxlag, single(hann(winsize+1)), 'corr');
% outCov = gausswc(single(a),single(b), winsize, maxlag, single(hann(winsize+1)), 'cov');
outCor = gausswc(single(a),single(b), winsize, maxlag, single(ones(winsize+1,1)), 'corr');
outCov = gausswc(single(a),single(b), winsize, maxlag, single(ones(winsize+1,1)), 'cov');
% outCor = gausswc(single(a),single(b), winsize, maxlag, single(gauss(winsize+1,1)'), 'corr');
% outCov = gausswc(single(a),single(b), winsize, maxlag, single(gauss(winsize+1,1)'), 'cov');
% outCor = repairSTWCPlot(outCor);
% outCov = repairSTWCPlot(outCov);

figure
subplot(3,1,1);
imagesc(t, -maxlag:maxlag,outCor);
% imagesc(t, -maxlag:maxlag,(outCor-mean(outCor(:)))/std(outCor(:)));
title('cor');

colorbar
% set(gca,'clim',[-.5 .5]);
subplot(3,1,2);
imagesc(t, -maxlag:maxlag,outCov);
% imagesc(t, -maxlag:maxlag,(outCov-mean(outCov(:)))/std(outCov(:)));
title('cov');
colorbar;
pos = get(gca, 'pos');

subplot(3,1,3);
plot(t,a, 'r');
hold on;
plot(t,b);
legend('m1','pmv');
title('signals');
set(gca, 'pos', get(gca ,'pos') .* [1 1 0 1] + [0 0 pos(3) 0]);
hold off;
axis tight;
