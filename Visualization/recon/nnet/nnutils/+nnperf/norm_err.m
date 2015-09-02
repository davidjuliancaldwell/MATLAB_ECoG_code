function e = norm_err(net,e)
%NN_NORMALIZE_ERRORS

% Copyright 2010-2012 The MathWorks, Inc.

outputInd = find(net.outputConnect);
numOutputs = length(outputInd);
if size(e,1) == numOutputs
  eInd = 1:numOutputs;
else
  eInd = outputInd;
end

Q = nnfast.numsamples(e);
Qones = ones(1,Q);

for ii = 1:numOutputs
  i = outputInd(ii);
  eind = eInd(ii);
  range = net.outputs{i}.range;
  rMin = range(:,1);
  rMax = range(:,2);
  ratio = 2 ./ (rMax - rMin);
  ratio(~isfinite(ratio)) = 1;
  ratio = ratio(:,Qones);
  for ts = 1:size(e,2)
    e{eind,ts} = bsxfun(@times,e{eind,ts},ratio);
  end
end
