function hints = dataHints(net,data,hints)

% Simulation Info
hints.doDelayedInputs = ~isfield(data,'Pd') || (sum(size(data.Pd))==0);
hints.doProcessInputs = (~isfield(data,'Pc') || (sum(size(data.Pc))==0)) && hints.doDelayedInputs;

% Performance Info
if isfield(data,'T')
  doEW = any(any(cell2mat(data.EW) ~= 1));
  [N_EW,Q_EW,TS_EW,M_EW] = nnsize(data.EW);
else
  doEW = false;
  N_EW = [];
  Q_EW = 0;
  TS_EW = 0;
  M_EW = 0;
end

% Combine Info
datahints = int64([...
  hints.doProcessInputs ...
  hints.doDelayedInputs ...
  doEW ...
  M_EW ...
  Q_EW ...
  TS_EW ...
  N_EW(:)' ...
  ]);

hints.long = [datahints hints.long];
