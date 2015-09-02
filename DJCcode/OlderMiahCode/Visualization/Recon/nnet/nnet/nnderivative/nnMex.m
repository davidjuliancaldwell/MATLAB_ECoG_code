function tools = nnMex(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.direction = 'default';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = 'double';

% Name
if isempty(hints.name)
  hints.name = 'MEX';
  if ~strcmp(hints.direction,'default')
    hints.name = [hints.name '(' hints.direction ')'];
  end
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nnMex.netCheck;

tools.netHints = @nnMex.netHints;
tools.dataHints = @nnMex.dataHints;
tools.codeHints = @nnMex.codeHints;

tools.formatData = @nnMex.formatData;
tools.formatNet = @nnMex.formatNet;

tools.setwb = @nnMex.setwb;
tools.getwb = @nnMex.getwb;

tools.pc = @nnMATLAB.pc; % TODO - C VERSION
tools.pd = @nnMATLAB.pd; % TODO - C VERSION
tools.y = @nnMex.y;

tools.trainPerf = @nnMex.trainPerf;
tools.trainValTestPerfs = @nnMex.trainValTestPerfs;

tools.grad = @nnMex.grad;
tools.perfsJEJJ = @nnMex.perfsJEJJ;
tools.perfsGrad = @nnMex.perfsGrad;


