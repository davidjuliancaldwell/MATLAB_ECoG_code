function pd = pd(net,Q,P,PD,i,j,ts,qq)
%NN_CALC_DELAYED_INPUTS Calculate or retrieve delayed inputs.

% Copyright 2010 The MathWorks, Inc.


numTS = length(ts);
delays = net.inputWeights{i,j}.delays;
if isempty(delays)
  if nargin < 8
    pd = zeros(0,Q);
  else
    pd = zeros(0,length(qq));
  end
  return
end

if nargin < 8
  
  if isempty(PD)
    if numTS == 1
      pd = nnfast.tapdelay(P,j,ts+net.numInputDelays,delays);
    else
      pd = cell(1,numTS);
      for k=1:numTS
        pd{k} = nnfast.tapdelay(P,j,ts(k)+net.numInputDelays,delays);
      end
      pd = [pd{:}];
    end
  else
    if numTS == 1
      pd = PD{i,j,ts};
    else
      pd = [PD{i,j,ts}];
    end
  end

else
  
  numTS = length(ts);
  if isempty(PD)
    if numTS == 1
      pd = nnfast.tapdelay(P,j,ts+net.numInputDelays,delays,qq);
    else
      pd = cell(1,numTS);
      for k=1:numTS
        pd{k} = nnfast.tapdelay(P,j,ts(k)+net.numInputDelays,delays,qq);
      end
      pd = [pd{:}];
    end
  else
    if numTS == 1
      pd = PD{i,j,ts}(:,qq);
    else
      pd = cell(1,ts);
      for tsi = ts, pd{tsi} = PD{i,j,tsi}(:,qq); end
      pd = [pd{:}];
    end
  end
  
end
