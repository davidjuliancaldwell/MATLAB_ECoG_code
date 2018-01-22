function [perf,data] = perf_all(net,data,fcns)

% Copyright 2010-2012 The MathWorks, Inc.

data = nn7.y_all(net,data,fcns);
fcn = fcns.perform;
perf = nncalc.perform(net,data.T,data.Y,data.EW,fcn.param);
data.perf = perf;
