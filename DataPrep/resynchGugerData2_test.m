T = 1e4;
N = 64;
fs = 1200;

x = sin(2*pi*180*(1:T)/fs)';

X = randn(T, N);

ampstarts = 1:16:64;
ampends = 16:16:64;

shifts = randi(16, length(ampstarts), 1)-8
% shifts(1) = 0;

for c = 1:N
    shift = shifts(find(c<=ampends, 1, 'first'));
    X(:, c) = circshift(x, shift);
end

sta.foo = randn(T, 1);
rX = resynchGugerData2(X, sta, [13]);

lags = calcLag2(rX, [], ampstarts(1):ampends(1));
doLagPlot(lags);
