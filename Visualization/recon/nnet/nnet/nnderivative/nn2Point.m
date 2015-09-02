function tools = tools(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.subcalc.name = 'default';
hints.delta = 1e-7;
hints.direction = 'positive';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = 'double';

% Name
if isempty(hints.name)
  hints.name = ['2-Point Numerical (' hints.subcalc.name ')'];
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nn2Point.netCheck;

tools.netHints = @nn2Point.netHints;
tools.dataHints = @nn2Point.dataHints;

tools.formatNet = @nn2Point.formatNet;
tools.formatData = @nn2Point.formatData;
tools.codeHints = @nn2Point.codeHints;

tools.setwb = @nn2Point.setwb;
tools.getwb = @nn2Point.getwb;

tools.pc = @nn2Point.pc;
tools.pd = @nn2Point.pd;
tools.y = @nn2Point.y;

tools.trainPerf = @nn2Point.trainPerf;
tools.trainValTestPerfs = @nn2Point.trainValTestPerfs;

tools.grad = @nn2Point.grad;
tools.perfsJEJJ = @nn2Point.perfsJEJJ;
tools.perfsGrad = @nn2Point.perfsGrad;
