N = 50;
runs = 1000;
p = .5;

vals = unifrnd(0, 1, [N, runs]);
vals = vals > p;

xs = sum(vals);
% [cts, bins] = hist(xs, unique(xs));
% stem(bins, cts/runs)
% hold all;
% plot(1:N, binopdf(1:N, N, p))

res = zeros(length(xs), 2);

for r = 1:runs
    res(r, 2) = binotest(xs(r), N, p);
    res(r, 1) = binotest2(xs(r), N, p);
end

subplot(211);
scatter(xs, res(:,1))
xlim([1 N])
hline(0.05)
subplot(212);
scatter(res(:,1), res(:,2))
% hold all
% scatter(xs, res(:,2))