clear res

for delta = 100%0:100
    x = zeros(10000,1);
    y = zeros(10000,1);

    idx = 5000;

    x(idx) = 10;
    y(idx+delta) = 10;

    win = 10;
    lag = 500;

    if (exist('res','var'))
        res = res + gausswc(single(x), single(y), win, lag, single(ones(win+1,1)), 'corr');
    else
        res = gausswc(single(x), single(y), win, lag, single(ones(win+1,1)), 'corr');
    end
end

figure
imagesc(1:length(x), -lag:lag, res);
ylim([-120 120]);
xlim([4950 5150]);
