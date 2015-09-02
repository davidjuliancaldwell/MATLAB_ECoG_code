function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

%hints.doDelayedInputs = ~isfield(data,'Pd') || (sum(size(data.Pd))==0);
%hints.doProcessInputs = (~isfield(data,'Pc') || (sum(size(data.Pc))==0)) && hints.doDelayedInputs;

if data.Q == 0
  hints.sliceSize = 0;
  hints.numSlices = 0;
else
  hints.sliceSize = ceil(data.Q/hints.reduction);
  hints.numSlices = ceil(data.Q/hints.sliceSize);
end

hints.sliceIndices = cell(1,hints.numSlices);
for i=1:hints.numSlices
  qstart = (i-1)*hints.sliceSize + 1;
  qstop = min(i*hints.sliceSize,data.Q);
  hints.sliceIndices{i} = qstart:qstop;
end

if isfield(data,'T')
  hints.doEW = any(any(cell2mat(data.EW) ~= 1));
else
  hints.doEW = false;
end

hints.subhints = hints.subcalc.dataHints(net,data,hints.subhints);
