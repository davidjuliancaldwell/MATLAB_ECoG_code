function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

hints.doDelayedInputs = ~isfield(data,'Pd') || (sum(size(data.Pd))==0);
hints.doProcessInputs = (~isfield(data,'Pc') || (sum(size(data.Pc))==0)) && hints.doDelayedInputs;

if isfield(data,'T')
  hints.doEW = any(any(cell2mat(data.EW) ~= 1));
  [hints.N_EW,hints.Q_EW,hints.TS_EW,hints.M_EW] = nnsize(data.EW);
else
  hints.doEW = false;
end
