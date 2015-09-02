function pd = delayed_inputs(net,P,PD,i,j,ts)
%CALC_DELAYED_INPUTS Calculated delayed inputs if not already cached

% Copyright 2010-2012 The MathWorks, Inc.

numTS = length(ts);
if ~isempty(PD)
  % Precalculated
  if numTS == 1
    pd = PD{i,j,ts};
  else
    pd = [PD{i,j,ts}];
  end
else
  % Recalculate
  if numTS == 1
    pd = nnfast.tapdelay(P,j,ts+net.numInputDelays,net.inputWeights{i,j}.delays);
  else
    pd = cell(1,numTS);
    for k=1:numTS
      pd{k} = nnfast.tapdelay(P,j,ts(k)+net.numInputDelays,net.inputWeights{i,j}.delays);
    end
    pd = [pd{:}];
  end
end
