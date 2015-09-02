function tools = tools(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.accuracy = 1e-9;
hints.relativeAccuracy = 1e-7;

hints.subcalcs = { ...
  nn2Point; ...
  nn5Point; ...
  nn7; ...
  nn7('direction','forward'); ...
  nn7('direction','backward'); ...
  nnSimple('direction','backward'); ...
  nnSimple('direction','forward'); ...
  nnMATLAB('direction','backward'); ...
  nnMATLAB('direction','forward'); ...
  nnMemReduc; ...
  ... %nnMex('direction','forward'); ...
  ... %nnMex('direction','backward'); ...
  ... % nncalc_gpu('direction','forward'), ...
  ... % nncalc_gpu('direction','backward'), ...
  };

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = hints.subcalcs{1}.hints.precision;

% Name
if isempty(hints.name)
  hints.name = 'Compare';
end
tools.hints = hints;
tools.name = hints.name;

% Dependent Hints
tools.hints.numTools = numel(tools.hints.subcalcs);

% Function Handles
tools.netCheck = @nnCompare.netCheck;

tools.netHints = @nnCompare.netHints;
tools.dataHints = @nnCompare.dataHints;
tools.codeHints = @nnCompare.codeHints;

tools.formatData = @nnCompare.formatData;
tools.formatNet = @nnCompare.formatNet;

tools.setwb = @nnCompare.setwb;
tools.getwb = @nnCompare.getwb;

tools.pc = @nnCompare.pc;
tools.pd = @nnCompare.pd;
tools.y = @nnCompare.y;

tools.trainPerf = @nnCompare.trainPerf;
tools.trainValTestPerfs = @nnCompare.trainValTestPerfs;

tools.grad = @nnCompare.grad;
tools.perfsJEJJ = @nnCompare.perfsJEJJ;
tools.perfsGrad = @nnCompare.perfsGrad;

