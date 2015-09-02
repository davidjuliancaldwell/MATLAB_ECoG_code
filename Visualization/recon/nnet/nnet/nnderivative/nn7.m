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
  hints.name = 'Version 7.0';
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

tools.netHints = @nn7.netHints;
tools.dataHints = @nn7.dataHints;
tools.codeHints = @nn7.codeHints;

tools.formatData = @nn7.formatData;
tools.formatNet = @nn7.formatNet;

tools.setwb = @nn7.setwb;
tools.getwb = @nn7.getwb;

tools.pc = @nn7.pc;
tools.pd = @nn7.pd;
tools.y = @nn7.y;

tools.trainPerf = @nn7.trainPerf;
tools.trainValTestPerfs = @nn7.trainValTestPerfs;

tools.grad = @nn7.grad;
tools.perfsJEJJ = @nn7.perfsJEJJ;
tools.perfsGrad = @nn7.perfsGrad;
