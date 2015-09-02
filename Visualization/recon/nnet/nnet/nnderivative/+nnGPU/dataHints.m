function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Simulation Info
hints.doDelayedInputs = true; % TODO
hints.doProcessInputs = false; % TODO

%hints.doDelayedInputs = ~isfield(data,'Pd') || (sum(size(data.Pd))==0);
%hints.doProcessInputs = (~isfield(data,'Pc') || (sum(size(data.Pc))==0)) && hints.doDelayedInputs;

hints.Q = data.Q;
hints.TS = data.TS;

if isa(data.X,'parallel.gpu.GPUArray')
  if numel(data.Pc) > 1
    hints.QAligned = size(data.Pc,1);
  else
    hints.QAligned = size(data.X,1);
  end
else
  hints.QAligned = ceil(data.Q/32)*32;
end

% Performance Info
if isfield(data,'T')
  if isa(data.EW,'parallel.gpu.GPUArray')
    Q_EW = find(gather(any(isfinite(data.EW),2)),1,'last');
    if (Q_EW > 1), Q_EW = data.Q; end
    doEW = any(any((data.EW(1:Q_EW,:) ~= 1),1),2);
    EWcols = size(data.EW,2);
    % Nx1 EW not supported with gpuArray supplied by user
    % It could be ambiguous with 1xTS EW.
    if EWcols == 1
      N_EW = 1;
      TS_EW = 1;
      M_EW = 1;
    elseif EWcols == TS
      N_EW = 1;
      TS_EW = TS;
      M_EW = 1;
    else
      N_EW = nn.output_sizes(net);
      TS_EW = TS;
      M_EW = numel(N_EW);
    end
  else
    doEW = any(any(cell2mat(data.EW) ~= 1));
    [N_EW,Q_EW,TS_EW,M_EW] = nnsize(data.EW);
  end

  if isa(data.EW,'parallel.gpu.GPUArray')
    hints.Q_EW_Aligned = size(data.EW,1);
  elseif (Q_EW == 1)
    hints.Q_EW_Aligned = 1;
  else
    hints.Q_EW_Aligned = hints.QAligned;
  end
else
  doEW = false;
  N_EW = [];
  Q_EW = 0;
  TS_EW = 0;
  M_EW = 0;
  hints.Q_EW_Aligned = 0;
end


% Combine Info
datahints = int64([...
  hints.doProcessInputs ...
  hints.doDelayedInputs ...
  doEW ...
  M_EW ...
  Q_EW ...
  hints.Q_EW_Aligned ...
  TS_EW ...
  N_EW(:)' ...
  ]);

hints.long = gpuArray([datahints hints.long]);
hints.double = gpuArray(hints.double);

% Kernel Info
switch hints.precision
  case 'double'
    hints.valSize = 8;
  case 'single'
    hints.valSize = 4;
end

% Pad 4-byte INT32 hints.long to multiple of size of 8-bytes.
if rem(numel(hints.long),2) ~= 0
  hints.long = [hints.long int64(0)];
end

% Hints Size
hints.sizeL = numel(hints.long);
hints.sizeD = numel(hints.double);
hints.sizeHints = hints.sizeL * 8 + hints.sizeD * hints.valSize;
