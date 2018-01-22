function tools = nnGPU(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.precision = 'double'; % 'single' or 'double'
hints.subcalc.name = 'default'; % 'none', 'default', calcMode
hints.defaultToCPU = true;

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);

% Name
if isempty(hints.name)
  hints.name = ['GPU(' hints.precision ')'];
end

% Constant Hints
hints.memAlign = 16; % Multiple of elements for GPU Memory address alignment
hints.maxBlockWidth = 32; % Used to pad samples with zeros for threads past Q

tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.netCheck = @nnGPU.netCheck;

tools.netHints = @nnGPU.netHints;
tools.dataHints = @nnGPU.dataHints;
tools.codeHints = @nnGPU.codeHints;

tools.formatNet = @nnGPU.formatNet;
tools.formatData = @nnGPU.formatData;

tools.setwb = @nnGPU.setwb;
tools.getwb = @nnGPU.getwb;

tools.pc = @nnGPU.pc;
tools.pd = ''; % TODO - GPU VERSION
tools.y = @nnGPU.y;

tools.trainPerf = @nnGPU.trainPerf;
tools.trainValTestPerfs = @nnGPU.trainValTestPerfs;

tools.grad = @nnGPU.grad;
tools.perfsJEJJ = @nnGPU.perfsJEJJ;
tools.perfsGrad = @nnGPU.perfsGrad;


