function Pd = pd(net,Pc,Q,TS,hints)
%NNCALC_MATLAB.PD

% Copyright 2012 The MathWorks, Inc.

numInputs = net.numInputs;
numLayers = net.numLayers;
NID = net.numInputDelays;
TS = size(Pc,2) - NID;

Pd = cell(numLayers,numInputs,TS);
if numel(Pd) == 0, return, end

Q = 0;
for i=1:numel(Pc)
  Q = size(Pc{i},2);
  if (Q > 0), break; end
end
P0 = zeros(0,Q);
for ts = 1:TS
  for i = 1:numLayers
    for j = 1:numInputs
      if (net.inputConnect(i,j))
        d = net.inputWeights{i,j}.delays;
        if (numel(d)==1) && (d == 0)
          Pd{i,j,ts} = Pc{j,ts+NID};
        else
          Pd{i,j,ts} = nnfast.tapdelay(Pc,j,ts+NID,net.inputWeights{i,j}.delays);
        end
      else
        Pd{i,j,ts} = P0;
      end
    end
  end
end
