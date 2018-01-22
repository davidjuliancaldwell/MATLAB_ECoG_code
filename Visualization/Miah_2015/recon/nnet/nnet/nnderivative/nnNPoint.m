function tools = tools(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.subcalc.name = 'default';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = 'double';

% Name
if isempty(hints.name)
  hints.name = ['N-Point Numerical (' hints.subcalc.name ')'];
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nnNPoint.netCheck;

tools.netHints = @nnNPoint.netHints;
tools.dataHints = @nnNPoint.dataHints;
tools.codeHints = @nnNPoint.codeHints;

tools.formatNet = @nnNPoint.formatNet;
tools.formatData = @nnNPoint.formatData;

tools.setwb = @nnNPoint.setwb;
tools.getwb = @nnNPoint.getwb;

tools.pc = @nnNPoint.pc;
tools.pd = @nnNPoint.pd;
tools.y = @nnNPoint.y;

tools.trainPerf = @nnNPoint.trainPerf;
tools.trainValTestPerfs = @nnNPoint.trainValTestPerfs;

tools.grad = @nnNPoint.grad;
tools.perfsJEJJ = @nnNPoint.perfsJEJJ;
tools.perfsGrad = @nnNPoint.perfsGrad;
