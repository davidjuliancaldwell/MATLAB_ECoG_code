function tools = tools(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.subcalc.name = 'default';
hints.delta = 1e-5;

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = 'double';

% Name
if isempty(hints.name)
  hints.name = ['5-Point Numerical (' hints.subcalc.name ')'];
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nn5Point.netCheck;

tools.netHints = @nn5Point.netHints;
tools.dataHints = @nn5Point.dataHints;
tools.codeHints = @nn5Point.codeHints;

tools.formatNet = @nn5Point.formatNet;
tools.formatData = @nn5Point.formatData;

tools.setwb = @nn5Point.setwb;
tools.getwb = @nn5Point.getwb;

tools.pc = @nn5Point.pc;
tools.pd = @nn5Point.pd;
tools.y = @nn5Point.y;

tools.trainPerf = @nn5Point.trainPerf;
tools.trainValTestPerfs = @nn5Point.trainValTestPerfs;

tools.grad = @nn5Point.grad;
tools.perfsJEJJ = @nn5Point.perfsJEJJ;
tools.perfsGrad = @nn5Point.perfsGrad;
