load 'test_triggeredAverage/data.mat';

[av, win, tAv, tWin] = triggeredAverage(diff(codes), 1.5, res, 5, 2000, 'testing file', 'test_triggeredAverage/output_figure');
