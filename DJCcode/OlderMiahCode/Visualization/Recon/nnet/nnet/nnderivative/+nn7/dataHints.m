function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

hints.doDelayedInputs = ~isfield(data,'Pd') || (sum(size(data.Pd))==0);
hints.doProcessInputs = (~isfield(data,'Pc') || (sum(size(data.Pc))==0)) && hints.doDelayedInputs;

if isfield(data,'T')
  hints.doEW = any(any(cell2mat(data.EW) ~= 1));
else
  hints.doEW = false;
end

