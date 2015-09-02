function [best,val_fail] = validation_start(net,perf,vperf);

% Copyright 2010 The MathWorks, Inc.

best.net = net;
best.perf = perf;
best.vperf = vperf;
val_fail = 0;
