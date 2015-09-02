function tools = tools(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.direction = 'default';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);

% Name
if isempty(hints.name)
  hints.name = 'Simple';
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

tools.netHints = @nnSimple.netHints;
tools.dataHints = @nnSimple.dataHints;
tools.codeHints = @nnSimple.codeHints;

tools.formatData = @nnSimple.formatData;
tools.formatNet = @nnSimple.formatNet;

tools.setwb = @nnSimple.setwb;
tools.getwb = @nnSimple.getwb;

tools.pc = @nnSimple.pc;
tools.pd = @nnSimple.pd;
tools.y = @nnSimple.y;

tools.trainPerf = @nnSimple.trainPerf;
tools.trainValTestPerfs = @nnSimple.trainValTestPerfs;

tools.grad = @nnSimple.grad;
tools.perfsJEJJ = @nnSimple.perfsJEJJ;
tools.perfsGrad = @nnSimple.perfsGrad;
