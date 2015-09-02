function [Y,Af] = y(net,data,hints)
%NNCALC_PARALLEL.Y

% Copyright 2012 The MathWorks, Inc.

if ~hints.isActiveWorker
  Y = [];
  Af = [];
  return
end

% Parallel Calculation
if nargout > 1
  [Yp,Afp] = hints.subcalc.y(net,data,hints.subhints);
else
  Yp = hints.subcalc.y(net,data,hints.subhints);
  Afp = [];
end

% Return Composite uncombined
if hints.isComposite
  Y = Yp;
  if (nargout > 1)
    Af = Afp;
  end
  return
end
  
% Send Result to Worker 1
if (labindex ~= hints.mainWorkerInd)
  results = {Yp,Afp};
  labSend(results,hints.mainWorkerInd);
  [Y,Af] = deal([]);
  return
end

% Combine Results on Main Worker
Y = cell(hints.numOutputs,hints.TS);

for i=1:hints.numOutputs
  Y(i,:) = {zeros(hints.output_sizes(i),hints.Q)};
end
if nargout >= 2
  Af = cell(hints.numLayers,hints.numLayerDelays);
  for i=1:hints.numLayers
    Af(i,:) = {zeros(hints.layer_sizes(i),hints.Q)};
  end
end

% Combine Slices
for s = 1:hints.numSlices

  fromLab = hints.workerInd(s);
  if (fromLab ~= labindex)
    [results,fromLab] = labReceive(fromLab); % 'any' results in bug!
    [Yp,Afp] = deal(results{:});
  end

  qq = hints.allSliceIndices{fromLab};
  for i=1:hints.numOutputs
    for ts = 1:hints.TS
      Y{i,ts}(:,qq) = Yp{i,ts};
    end
  end

  if nargout >= 2
    for i=1:hints.numLayers
      for ts = 1:hints.numLayerDelays
        Af{i,ts}(:,qq) = Afp{i,ts};
      end
    end
  end
end

