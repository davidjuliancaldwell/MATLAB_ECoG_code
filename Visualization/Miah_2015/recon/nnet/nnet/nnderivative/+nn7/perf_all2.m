function [perf,Y,Ac,N,Zb,Zi,Zl] = perf_all2(net,~,Pd,T,Ai,EW,Q,TS,fcns)

% Copyright 2010-2012 The MathWorks, Inc.

data.X = {};
data.Xi = {};
data.Pc = {};
data.Pd = Pd;
data.Ai = Ai;
data.EW = {1};
data.Q = Q;
data.TS = TS;

data = nn7.y_all(net,data,fcns);
fcn = fcns.perform;
Y = data.Y;
perf = nncalc.perform(net,T,Y,data.EW,fcn.param);
Ac = data.Ac;
N = data;
Zb = data.Zb;
Zi = data.Zi;
Zl = data.Zl;
