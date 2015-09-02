%% stwc test
addpath ./scripts

%% make three waveforms, with transient lagged correlations
t = 1:3000;
eps = .2;
A = 1;

X = eps*randn(length(t), 2);
adder = A*sin(2*pi*(0:0.01:1))';

lAdder = 1:length(adder);

truelag = -30;

X(lAdder+1000,         1) = X(lAdder+1000, 1) + adder;
X(lAdder+1000+truelag, 2) = X(lAdder+1000+truelag, 2) + adder;

plot(X);

legend('channel 1', 'channel 2');

%% perform stwc

% stwc(X, pairs, maxlag, windowWidth)

vals = gausswc(single(X(:,1)), single(X(:,2)), 100, 200, single(ones(101, 1)), 'cor');
% vals = repairSTWCPlot(vals);
[a,b,c] = findBestLag(vals, 1:size(vals, 2), -200:200, [], true);
imagesc(1:size(vals,2), -200:200, vals);
colorbar;

vline(b,'k');
hline(c,'k');

fprintf('channel 2 lags channel 1 by a true lag of %d samples, we detected a lag of %d samples\n', truelag, c);

% a positive lag implies that the first channel is leading
% a negative lag implies that the second channel is leading
