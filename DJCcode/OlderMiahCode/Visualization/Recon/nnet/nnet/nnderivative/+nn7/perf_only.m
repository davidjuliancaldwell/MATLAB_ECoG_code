function perf = perf_only(net,data,fcns)

% Copyright 2010-2012 The MathWorks, Inc.

Y = nn7.y(net,data,fcns);
fcn = fcns.perform;
perf = nncalc.perform(net,data.T,Y,data.EW,fcn.param);
data.perf = perf;
