function Pc = pc(net,X,Xi,Q,TS,hints)

% Copyright 2012 The MathWorks, Inc.

Pc = hints.subcalc.pc(net,X,Xi,Q,TS,hints.subhints);
