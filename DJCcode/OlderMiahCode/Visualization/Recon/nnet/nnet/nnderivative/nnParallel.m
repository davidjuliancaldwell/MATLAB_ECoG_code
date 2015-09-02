function tools = nnParallel(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.subcalc.name = 'default';
hints.onlyGPUs = false;
hints.precision = 'double';
hints.direction = 'default';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);

% Name
if isempty(hints.name)
  hints.name = ['Parallel(' hints.subcalc.name ')'];
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nnParallel.netCheck;

tools.netHints = @nnParallel.netHints;
tools.dataHints = @nnParallel.dataHints;
tools.codeHints = @nnParallel.codeHints;

tools.formatData = @nnParallel.formatData;
tools.formatNet = @nnParallel.formatNet;

tools.setwb = @nnParallel.setwb;
tools.getwb = @nnParallel.getwb;

tools.pc = @nnParallel.pc;
tools.pd = @nnParallel.pd;
tools.y = @nnParallel.y;

tools.trainPerf = @nnParallel.trainPerf;
tools.trainValTestPerfs = @nnParallel.trainValTestPerfs;

tools.grad = @nnParallel.grad;
tools.perfsJEJJ = @nnParallel.perfsJEJJ;
tools.perfsGrad = @nnParallel.perfsGrad;
