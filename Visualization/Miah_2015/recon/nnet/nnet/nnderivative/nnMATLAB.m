function tools = tools(varargin)

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
  hints.name = 'MATLAB';
  optList = {};
  if ~strcmp(hints.direction,'default')
    optList{end+1} = hints.direction;
  end
  if ~isempty(optList)
    hints.name = [hints.name ' ' nnstring.parenCommaList(optList)];
  end
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nnMATLAB.netCheck;

tools.netHints = @nnMATLAB.netHints;
tools.dataHints = @nnMATLAB.dataHints;
tools.codeHints = @nnMATLAB.codeHints;

tools.formatData = @nnMATLAB.formatData;
tools.formatNet = @nnMATLAB.formatNet;

tools.setwb = @nnMATLAB.setwb;
tools.getwb = @nnMATLAB.getwb;

tools.pc = @nnMATLAB.pc;
tools.pd = @nnMATLAB.pd;
tools.y = @nnMATLAB.y;

tools.trainPerf = @nnMATLAB.trainPerf;
tools.trainValTestPerfs = @nnMATLAB.trainValTestPerfs;

tools.grad = @nnMATLAB.grad;
tools.perfsJEJJ = @nnMATLAB.perfsJEJJ;
tools.perfsGrad = @nnMATLAB.perfsGrad;

