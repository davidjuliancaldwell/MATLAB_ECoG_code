function Pd = pd(net,Pc,Q,TS,hints)

% Copyright 2012 The MathWorks, Inc.

Pd = hints.subcalc.pd(net,Pc,Q,TS,hints.subhints);
